enum ActionType {
  created,
  updated,
  deleted,
}

class ActionMessage {
  static const created = "Data created successfully";
  static const updated = "Data updated successfully";
  static const deleted = "Data deleted successfully";

  static const createFailed = "Failed to create data";
  static const updateFailed = "Failed to update data";
  static const deleteFailed = "Failed to delete data";
}

class ActionResult {
  final ActionType action;
  final String message;

  ActionResult(this.action, this.message);
}
