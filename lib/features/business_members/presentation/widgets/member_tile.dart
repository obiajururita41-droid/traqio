import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/business/business.dart';
import 'package:traqio/core/business/capabilities_provider.dart';
import 'package:traqio/core/business/capability.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/business_members/domain/entities/business_member.dart';
import 'package:traqio/features/business_members/presentation/providers/member_action_controller.dart';

class MemberTile extends ConsumerWidget {
  final BusinessMember member;
  const MemberTile({super.key, required this.member});

  Color _roleColor(MemberRole role) {
    switch (role) {
      case MemberRole.owner: return Colors.purple;
      case MemberRole.admin: return Colors.blue;
      case MemberRole.staff: return Colors.grey;
    }
  }

  void _showRoleMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Make Admin'),
              onTap: () {
                Navigator.pop(context);
                ref.read(memberActionControllerProvider.notifier)
                    .updateRole(memberId: member.id, newRole: MemberRole.admin);
              },
            ),
            ListTile(
              title: const Text('Make Staff'),
              onTap: () {
                Navigator.pop(context);
                ref.read(memberActionControllerProvider.notifier)
                    .updateRole(memberId: member.id, newRole: MemberRole.staff);
              },
            ),
            ListTile(
              title: Text('Remove from team', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                ref.read(memberActionControllerProvider.notifier).remove(member.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final canManage = ref.watch(hasCapabilityProvider(Capability.manageMembers));
    final roleColor = _roleColor(member.role);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: roleColor.withValues(alpha: 0.12),
            child: Text(
              member.nameOrEmail.isNotEmpty ? member.nameOrEmail[0].toUpperCase() : '?',
              style: theme.textTheme.titleMedium?.copyWith(color: roleColor),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.nameOrEmail, style: theme.textTheme.titleMedium,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(member.role.name, style: theme.textTheme.labelSmall?.copyWith(color: roleColor)),
                    ),
                    if (member.isPending) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text('Invited', style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          )),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (canManage && !member.isOwner)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showRoleMenu(context, ref),
            ),
        ],
      ),
    );
  }
}
