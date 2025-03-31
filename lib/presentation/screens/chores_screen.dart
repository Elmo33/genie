import 'package:flutter/material.dart';
import 'package:genie/data/models/chore.dart'; // Correct import
import 'package:genie/data/services/chore_service.dart'; // Correct import
import 'package:genie/data/services/user_service.dart'; // For getting user ID
import 'package:genie/presentation/widgets/chores/chore_list_item.dart'; // Use dedicated item widget
import 'package:genie/presentation/widgets/common/loading_indicator.dart'; // Use common widgets
import 'package:genie/presentation/widgets/common/error_display.dart'; // Use common widgets
import 'package:genie/presentation/widgets/shared/base_screen.dart'; // For layout consistency if needed standalone

class ChoreScreen extends StatefulWidget {
  const ChoreScreen({super.key});

  @override
  State<ChoreScreen> createState() => _ChoreScreenState();
}

class _ChoreScreenState extends State<ChoreScreen> {
  List<Chore> _chores = [];
  bool _isLoading = true;
  String? _error;
  final int _currentUserId = UserService.getCurrentUserId(); // Get static user ID

  @override
  void initState() {
    super.initState();
    _fetchChores();
  }

  Future<void> _fetchChores() async {
    if (!mounted) return; // Avoid setState after dispose
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final chores = await ChoreService.fetchChores();
      if (mounted) {
        setState(() {
          _chores = chores;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load chores: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteChore(int id) async {
    // Optional: Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this chore?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true) return;

    // Optimistic UI update (remove immediately)
    final index = _chores.indexWhere((c) => c.id == id);
    Chore? choreToRemove;
    if (index != -1) {
      choreToRemove = _chores[index];
      setState(() {
        _chores.removeAt(index);
      });
    }

    try {
      final success = await ChoreService.deleteChore(id);
      if (!success && mounted) {
        // Revert optimistic update on failure
        if(choreToRemove != null && index != -1) {
          setState(() {
            _chores.insert(index, choreToRemove!);
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete chore. It might have already been deleted.")),
        );
      } else if (success && mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Chore deleted."), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      // Revert optimistic update on error
      if(choreToRemove != null && index != -1) {
        setState(() {
          _chores.insert(index, choreToRemove!);
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting chore: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _completeChore(int choreId) async {
    // Optional: show loading indicator on the specific item?
    final choreIndex = _chores.indexWhere((c) => c.id == choreId);
    // Maybe disable the button while processing?

    try {
      final completion = await ChoreService.completeChore(choreId, _currentUserId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Chore '${_chores[choreIndex].name}' completed!"), duration: Duration(seconds: 2)),
        );
        // Optional: Refresh list to show updated completion history if displayed
        _fetchChores(); // Simple refresh
        // Or: Update the specific chore item in the list if displaying completion status directly
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error completing chore: ${e.toString()}")),
        );
      }
    } finally {
      // Re-enable button etc.
    }
  }

  // Grouping logic remains similar but uses the updated Chore model
  Map<String, List<Chore>> _groupChoresByRoom(List<Chore> chores) {
    final Map<String, List<Chore>> grouped = {};
    for (final chore in chores) {
      grouped.putIfAbsent(chore.room, () => []).add(chore);
    }
    // Sort rooms alphabetically maybe?
    final sortedKeys = grouped.keys.toList()..sort();
    return {for (var key in sortedKeys) key: grouped[key]!};
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_isLoading) {
      body = const Center(child: LoadingIndicator());
    } else if (_error != null) {
      body = Center(child: ErrorDisplay(message: _error!, onRetry: _fetchChores));
    } else if (_chores.isEmpty) {
      body = Center(
          child: Text("No chores found. Add some via chat!", style: Theme.of(context).textTheme.titleMedium)
      );
    }
    else {
      final choresByRoom = _groupChoresByRoom(_chores);
      body = RefreshIndicator(
        onRefresh: _fetchChores,
        child: ListView.builder(
            itemCount: choresByRoom.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final roomName = choresByRoom.keys.elementAt(index);
              final choresInRoom = choresByRoom[roomName]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                        roomName,
                        style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                  ),
                  // Using ListView.separated for dividers
                  ListView.separated(
                    shrinkWrap: true, // Important inside another ListView
                    physics: const NeverScrollableScrollPhysics(), // Important
                    itemCount: choresInRoom.length,
                    itemBuilder: (ctx, choreIndex) {
                      final chore = choresInRoom[choreIndex];
                      return ChoreListItem(
                        chore: chore,
                        currentUserId: _currentUserId, // Pass user ID for assignment check
                        onDelete: () => _deleteChore(chore.id),
                        onComplete: () => _completeChore(chore.id),
                      );
                    },
                    separatorBuilder: (ctx, i) => const Divider(color: Colors.white12, height: 1),
                  ),
                  const SizedBox(height: 16), // Space between rooms
                ],
              );
            }
        ),
      );
    }

    // Use BaseScreen for consistent AppBar and background
    return BaseScreen(
      // AppBar is handled by BaseScreen
      body: body,
      withChat: false, // Don't embed chat within the chores list screen itself
    );
  }
}