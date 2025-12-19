import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/data_models.dart';
import '../../theme.dart';
import '../../services/supabase_service.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;
    final name = user?.userMetadata?['full_name'] ?? 'Usuario';
    // Use first name for greeting if no DJ alias
    final firstName = name.split(' ').first;
    final djAlias = user?.userMetadata?['dj_alias'];
    final displayName =
        (djAlias != null && djAlias.isNotEmpty) ? djAlias : firstName;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                'Hola, $displayName 👋',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Maintenance Reward Card (animated)
              Builder(builder: (context) {
                final target = 5;
                // For now, use mock user stat as a stand-in. When backend is ready,
                // wire this to the user's completed preventive maintenances delivered.
                final completed =
                    MockData.currentUser.totalRepairs.clamp(0, target);
                return MaintenanceProgressCard(
                    completed: completed, target: target);
              }),
              const SizedBox(height: 32),

              // My Equipment Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mis Equipos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver Todo'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: MockData.myEquipment.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return _EquipmentCard(
                        equipment: MockData.myEquipment[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  final Equipment equipment;

  const _EquipmentCard({required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              equipment.thumbnail,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipment.brand,
                  style: TextStyle(
                    color: BrandColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  equipment.model,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatusBadge(status: equipment.status),
                    const Spacer(),
                    Text(
                      'ID: ${equipment.id}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final EquipmentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case EquipmentStatus.available:
        color = Colors.green;
        label = 'Disponible';
        break;
      case EquipmentStatus.repair:
        color = Colors.orange;
        label = 'En Taller';
        break;
      case EquipmentStatus.rented:
        color = Colors.red;
        label = 'Alquilado';
        break;
      default:
        color = Colors.grey;
        label = 'Otro';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// A modern, animated card that shows the user's progress toward
/// earning a 50% discount on the next preventive maintenance.
class MaintenanceProgressCard extends StatelessWidget {
  final int completed;
  final int target;

  const MaintenanceProgressCard(
      {super.key, required this.completed, required this.target});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final on = cs.onPrimary;
    final total = target <= 0 ? 1 : target;
    final safeCompleted = completed.clamp(0, total);
    final percent = safeCompleted / total;
    final remaining = (total - safeCompleted).clamp(0, total);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary,
            Color.alphaBlend(Colors.black.withValues(alpha: 0.1), cs.primary),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.build_rounded, color: on),
            const SizedBox(width: 8),
            Text('Progreso de mantenimiento',
                style: TextStyle(color: on, fontWeight: FontWeight.w600)),
            const Spacer(),
            _DiscountBadge(color: on, textColor: cs.primary),
          ]),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('$safeCompleted',
                  style: TextStyle(
                      color: on, fontSize: 28, fontWeight: FontWeight.bold)),
              Text(' de $total',
                  style: TextStyle(
                      color: on.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              Expanded(
                  child:
                      StepDots(total: total, active: safeCompleted, color: on)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: percent),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.black.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(on),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            remaining > 0
                ? 'Te faltan $remaining mantenimiento${remaining == 1 ? '' : 's'} para obtener 50% OFF en tu próximo preventivo.'
                : '¡Listo! Ya tienes tu 50% OFF para el próximo mantenimiento preventivo.',
            style: TextStyle(color: on.withValues(alpha: 0.95), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  final Color color;
  final Color textColor;

  const _DiscountBadge({required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Row(children: [
        Icon(Icons.local_offer_rounded, color: textColor, size: 16),
        const SizedBox(width: 6),
        Text('50% OFF',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// Small step indicator dots representing completed vs target maintenances.
class StepDots extends StatelessWidget {
  final int total;
  final int active;
  final Color color;

  const StepDots(
      {super.key,
      required this.total,
      required this.active,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final count = total <= 0 ? 1 : total;
    final act = active.clamp(0, count);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(count, (i) {
        final isOn = i < act;
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
          decoration: BoxDecoration(
            color: isOn ? color : color.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
