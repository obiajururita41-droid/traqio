/// Capability keys must exactly match the `key` column in the
/// `capabilities` table. Adding a new capability means adding a row
/// there (plus role_capabilities mappings) — no Dart changes needed
/// beyond referencing the new key where relevant.
class Capability {
  Capability._();

  static const manageBusinessSettings = 'manage_business_settings';
  static const manageBilling = 'manage_billing';
  static const deleteBusiness = 'delete_business';
  static const manageMembers = 'manage_members';
  static const inviteStaff = 'invite_staff';
  static const managePurchaseOrders = 'manage_purchase_orders';
  static const manageInvoices = 'manage_invoices';
  static const manageReports = 'manage_reports';
}
