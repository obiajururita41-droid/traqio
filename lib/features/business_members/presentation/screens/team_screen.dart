import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/business/business.dart';
import 'package:traqio/core/business/capabilities_provider.dart';
import 'package:traqio/core/business/capability.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/business_members/presentation/providers/business_member_providers.dart';
import 'package:traqio/features/business_members/presentation/providers/member_action_controller.dart';
import 'package:traqio/features/business_members/presentation/widgets/member_tile.dart';

class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  void _openInviteSheet(BuildContext context, WidgetRef ref, bool canInviteAnyRole) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _InviteMemberSheet(canInviteAnyRole: canInviteAnyRole),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(businessMembersProvider);
    final canManageMembers = ref.watch(hasCapabilityProvider(Capability.manageMembers));
    final canInviteStaff = ref.watch(hasCapabilityProvider(Capability.inviteStaff));
    final canInvite = canManageMembers || canInviteStaff;

    final actionState = ref.watch(memberActionControllerProvider);

    ref.listen(memberActionControllerProvider, (previous, next) {
      if (next is MemberActionError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.failure.message)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      floatingActionButton: canInvite
          ? FloatingActionButton.extended(
              onPressed: actionState is MemberActionLoading
                  ? null
                  : () => _openInviteSheet(context, ref, canManageMembers),
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Invite'),
            )
          : null,
      body: SafeArea(
        child: membersAsync.when(
          data: (members) {
            if (members.isEmpty) {
              return Center(
                child: Text('No team members yet', style: theme.textTheme.titleMedium),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(businessMembersProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: members.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) => MemberTile(member: members[index]),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Could not load team: $e')),
        ),
      ),
    );
  }
}

class _InviteMemberSheet extends ConsumerStatefulWidget {
  final bool canInviteAnyRole;
  const _InviteMemberSheet({required this.canInviteAnyRole});

  @override
  ConsumerState<_InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends ConsumerState<_InviteMemberSheet> {
  final _emailController = TextEditingController();
  MemberRole _role = MemberRole.staff;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address')),
      );
      return;
    }
    ref.read(memberActionControllerProvider.notifier).invite(email: email, role: _role);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionState = ref.watch(memberActionControllerProvider);
    final isLoading = actionState is MemberActionLoading;

    ref.listen(memberActionControllerProvider, (previous, next) {
      if (next is MemberActionSuccess) {
        Navigator.of(context).pop();
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl, right: AppSpacing.xl, top: AppSpacing.xl,
        bottom: AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Invite Team Member', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email address'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Role', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (widget.canInviteAnyRole)
                ChoiceChip(
                  label: const Text('Admin'),
                  selected: _role == MemberRole.admin,
                  onSelected: (_) => setState(() => _role = MemberRole.admin),
                ),
              ChoiceChip(
                label: const Text('Staff'),
                selected: _role == MemberRole.staff,
                onSelected: (_) => setState(() => _role = MemberRole.staff),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Send Invite'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'They\'ll join automatically when they sign up or log in with this email.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
