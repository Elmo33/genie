class AppConstants {
  // --- API Configuration ---
  // IMPORTANT: Replace with your actual backend IP/domain if not running locally
  static const String _apiBaseUrl = "http://127.0.0.1:8000";
  static const String _apiPrefix = "/api/v1";

  static const String apiBaseUrl = _apiBaseUrl + _apiPrefix;
  static const String chatApiUrl = "$apiBaseUrl/chat";
  static const String choresApiUrl = "$apiBaseUrl/chores";
  static const String usersApiUrl = "$apiBaseUrl/users";

  // --- Default Values ---
  static const String defaultRoomName = "General";

  // --- Static User Info (Temporary) ---
  // Replace this with actual authentication/user selection logic later
  static const int currentUserId = 1; // Example static user ID
  static const String currentUsername = "StaticUser"; // Example static username

  // --- Test User ---
  static const String testUsername = "testuser";
  static const String testUserEmail = "test@example.com";

}