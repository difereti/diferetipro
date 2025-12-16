import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/data_models.dart';
import '../../theme.dart';

class TechnicianKanbanPage extends StatelessWidget {
  const TechnicianKanbanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Group repairs by status (mocked logic)
    final pending = MockData.repairs; // Using same list for demo
    final inProgress = <Repair>[]; 
    final completed = <Repair>[];

    return Center(
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        children: [
          _KanbanColumn(title: 'Por Revisar', color: Colors.orange, items: pending),
          const SizedBox(width: 16),
          _KanbanColumn(title: 'En Reparación', color: Colors.blue, items: inProgress),
          const SizedBox(width: 16),
          _KanbanColumn(title: 'Listo', color: Colors.green, items: completed),
        ],
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final Color color;
  final List<Repair> items;

  const _KanbanColumn({
    required this.title,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(color: color, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _RepairCard(repair: items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RepairCard extends StatelessWidget {
  final Repair repair;

  const _RepairCard({required this.repair});

  @override
  Widget build(BuildContext context) {
    // Find equipment for this repair
    final equipment = MockData.myEquipment.firstWhere(
      (e) => e.id == repair.equipmentId,
      orElse: () => MockData.myEquipment[0],
    );

    return Draggable<Repair>(
      data: repair,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(equipment.model),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: _buildCardContent(context, equipment)),
      child: _buildCardContent(context, equipment),
    );
  }

  Widget _buildCardContent(BuildContext context, Equipment equipment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  equipment.id,
                  style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${equipment.brand} ${equipment.model}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            repair.diagnosis.isNotEmpty ? repair.diagnosis : 'Pendiente diagnóstico',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                radius: 10,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=u1'),
              ),
              const SizedBox(width: 8),
              const Spacer(),
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              const Text('2d', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
