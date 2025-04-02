import 'package:flutter/material.dart';
import 'package:genie/data/models/user.dart'; // Make sure this file defines BOTH User and UserScore
import 'package:genie/data/services/user_service.dart';
import 'package:genie/presentation/widgets/common/loading_indicator.dart';
import 'package:genie/presentation/widgets/common/error_display.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  // Loading states
  bool _isLoading = false; // General loading (login, save)
  bool _isDeleting = false; // Specific loading for delete action
  bool _isScoreLoading = false; // Specific loading for score fetch

  // State
  bool _isLoggedIn = false;
  User? _currentUser;
  UserScore? _userScore; // Use the updated UserScore model

  // Errors
  String? _error; // General error (login, save, delete)
  String? _scoreError; // Specific error for score fetch

  // Controllers for editing
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  final _formKey = GlobalKey<FormState>(); // For validation

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    // Optional: Try to auto-login if a user session exists (not implemented here)
    // _checkInitialLoginState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // --- Action Handlers ---

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _isScoreLoading = true; // Also loading score on login
      _error = null;
      _scoreError = null; // Clear previous score error
    });
    try {
      final user = await UserService.loginOrCreateTestUser();
      UserScore? score;
      String? scoreFetchError;
      try {
        score = await UserService.fetchUserScore(user.id);
      } catch (e) {
        print("Score fetch failed during login: $e");
        // Provide user-friendly error messages based on exception type
        if (e.toString().contains('Score data not found')) {
          scoreFetchError = "No score data available for this month.";
        } else if (e.toString().contains('Failed to parse') || e.toString().contains('FormatException')) {
          scoreFetchError = "Error reading score data from server.";
        } else if (e.toString().contains('Network error')) {
          scoreFetchError = "Network error: Could not load score.";
        } else {
          // Generic fallback for other errors
          scoreFetchError = "Could not load score (unexpected error).";
        }
      }

      if (mounted) {
        setState(() {
          _currentUser = user;
          _userScore = score;
          _scoreError = scoreFetchError;
          _isLoggedIn = true;
          _isLoading = false;
          _isScoreLoading = false;
          _usernameController.text = user.username;
          _emailController.text = user.email ?? '';
        });
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text("Logged in as ${user.username}"), duration: const Duration(seconds: 2)),
          );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Login failed: ${e.toString()}";
          _isLoading = false;
          _isScoreLoading = false;
          _isLoggedIn = false;
          _currentUser = null;
          _userScore = null; // Clear score if login fails
          _scoreError = null; // Clear score error if login fails
        });
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return; // Don't save if validation fails
    }
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true; // Use _isLoading for saving as well
      _error = null;
    });

    try {
      final String newUsername = _usernameController.text.trim();
      final String newEmail = _emailController.text.trim();
      String? usernameToSend;
      String? emailToSend;

      // Only send if changed
      if(newUsername != _currentUser!.username){
        usernameToSend = newUsername;
      }
      // Handle empty email correctly
      final currentEmail = _currentUser!.email ?? '';
      if(newEmail != currentEmail){
        emailToSend = newEmail.isEmpty ? '' : newEmail; // Send empty string if cleared
      }

      if (usernameToSend == null && emailToSend == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text("No changes detected."), duration: Duration(seconds: 2)),
            );
        }
        return;
      }

      final updatedUser = await UserService.updateUser(
        _currentUser!.id,
        newUsername: usernameToSend,
        newEmail: emailToSend,
      );

      if (mounted) {
        setState(() {
          _currentUser = updatedUser; // Update local user state
          _isLoading = false;
          _usernameController.text = updatedUser.username;
          _emailController.text = updatedUser.email ?? '';
        });
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text("User details saved!"), duration: Duration(seconds: 2)),
          );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Save failed: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  void _handleLogout() {
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _currentUser = null;
        _userScore = null;
        _error = null; // Clear errors on logout
        _scoreError = null;
        _usernameController.clear();
        _emailController.clear();
        _formKey.currentState?.reset(); // Reset validation state
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text("Logged out."), duration: Duration(seconds: 2)),
        );
    }
    // In a real app: clear tokens, navigate away, etc.
  }

  Future<void> _handleDeleteAccount() async {
    if (_currentUser == null || _isDeleting || _isLoading) return;

    // --- Confirmation Dialog ---
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete your account?'),
                Text('This action cannot be undone.', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Not confirmed
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmed
              },
            ),
          ],
        );
      },
    );

    // --- Process Deletion ---
    if (confirmed == true) {
      setState(() {
        _isDeleting = true;
        _error = null; // Clear previous errors
      });

      try {
        await UserService.deleteUser(_currentUser!.id);
        if (mounted) {
          // Perform logout actions after successful deletion
          setState(() {
            _isDeleting = false;
            _isLoggedIn = false;
            _currentUser = null;
            _userScore = null;
            _scoreError = null;
            _usernameController.clear();
            _emailController.clear();
            _formKey.currentState?.reset();
          });
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text("Account deleted successfully."), duration: Duration(seconds: 3)),
            );
          // Optionally navigate away:
          // if(Navigator.canPop(context)) { Navigator.of(context).pop(); }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            // Provide a clearer deletion error message
            _error = "Deletion failed: ${e.toString().replaceFirst('Exception: ', '')}";
            _isDeleting = false;
          });
        }
      }
    }
  }

  // --- Build Methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView( // Keep scrollable
          padding: const EdgeInsets.all(24.0),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Initial Loading (only before login attempt)
    if (_isLoading && !_isLoggedIn && !_isDeleting) {
      return const LoadingIndicator();
    }

    // Display general errors (Login, Save, Delete)
    if (_error != null) {
      VoidCallback? retryAction;
      bool showDismissButton = false;

      // Determine retry action based on context
      if (_error!.startsWith("Deletion failed")) {
        retryAction = null; // Don't automatically retry delete
        showDismissButton = true; // Allow user to dismiss the error
      } else if (_isLoggedIn) {
        // If logged in, error was likely Save
        retryAction = _isLoading ? null : _handleSave;
      } else {
        // If not logged in, error was likely Login
        retryAction = _isLoading ? null : _handleLogin;
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ErrorDisplay(message: _error!, onRetry: retryAction),
          if (showDismissButton) ...[
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () => setState(() => _error = null),
                child: const Text('Dismiss')
            )
          ]
        ],
      );
    }

    // Login Button
    if (!_isLoggedIn) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.login),
        label: const Text('Login / Create Test User'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87, backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: _isLoading ? null : _handleLogin,
      );
    }

    // --- Logged In View ---
    // Safety check (should not be needed if logic is correct)
    if (_currentUser == null) {
      return const ErrorDisplay(message: "Internal error: User data missing.", onRetry: null);
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons stretch
        children: [
          // --- User Info Section ---
          Text("User Profile", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.account_circle_outlined, "Username: ${_currentUser!.username}", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.perm_identity, "User ID: ${_currentUser!.id}"),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today_outlined, "Joined: ${_currentUser!.createdAt.toLocal().toString().substring(0, 10)}"),
          const SizedBox(height: 8),
          _buildScoreDisplay(), // Display score info here
          const Divider(height: 32, thickness: 1),

          // --- Edit Form Section ---
          Text("Edit Details", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Username cannot be empty';
              if (value.trim().length < 3) return 'Username must be at least 3 characters';
              return null;
            },
            enabled: !_isLoading && !_isDeleting, // Disable field while saving/deleting
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Optional',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null; // Optional
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value.trim())) return 'Please enter a valid email address';
              return null;
            },
            enabled: !_isLoading && !_isDeleting,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54)) : const Icon(Icons.save_alt_outlined),
            label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black87, backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(150, 45),
            ),
            onPressed: _isLoading || _isDeleting ? null : _handleSave,
          ),
          const Divider(height: 32, thickness: 1),

          // --- Actions Section ---
          Text("Account Actions", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          OutlinedButton.icon( // Use OutlinedButton for logout
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blueGrey,
              side: const BorderSide(color: Colors.blueGrey),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(150, 45),
            ),
            onPressed: _isLoading || _isDeleting ? null : _handleLogout,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: _isDeleting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.delete_forever_outlined),
            label: Text(_isDeleting ? 'Deleting...' : 'Delete Account'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.red.shade700, // Destructive action style
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(150, 45),
            ),
            onPressed: _isLoading || _isDeleting ? null : _handleDeleteAccount,
          ),
        ],
      ),
    );
  }

  // Helper to build consistent info rows
  Widget _buildInfoRow(IconData icon, String text, {TextStyle? style}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: style ?? Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }

  // Updated score display widget based on the new UserScore model
  Widget _buildScoreDisplay() {
    const scoreIcon = Icon(Icons.scoreboard_outlined, size: 18, color: Colors.grey);

    if (_isScoreLoading) {
      return Row(
        children: [
          scoreIcon,
          const SizedBox(width: 8),
          const Text("Loading score..."),
          const SizedBox(width: 8),
          Container( // Constrain size of indicator
              margin: const EdgeInsets.only(top: 2.0), // Align vertically slightly better
              height: 14,
              width: 14,
              child: const CircularProgressIndicator(strokeWidth: 2)
          ),
        ],
      );
    }

    if (_scoreError != null) {
      // Display the specific score error
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align icon nicely if text wraps
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
                  _scoreError!,
                  style: TextStyle(color: Colors.orange.shade900)
              )
          ),
          // Optional: Add a retry button specifically for score
          // IconButton(icon: Icon(Icons.refresh), onPressed: _fetchScoreManually, visualDensity: VisualDensity.compact, tooltip: "Retry Score Load")
        ],
      );
    }

    if (_userScore != null) {
      // Display the score for the month from the updated model
      return _buildInfoRow(Icons.scoreboard_outlined, "Score (This Month): ${_userScore!.scoreThisMonth}");
    }

    // Fallback if score is null, no error, and not loading
    return _buildInfoRow(Icons.scoreboard_outlined, "Score: Not available", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey));
  }
} // End of _UserSettingsScreenState