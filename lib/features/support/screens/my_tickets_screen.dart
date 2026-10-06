import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import 'contact_us_screen.dart';

/// Lists the signed-in user's support tickets (`GET /api/support-tickets/`).
class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SupportProvider>().fetchTickets();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'in_progress':
        return AppTheme.warning;
      case 'resolved':
        return AppTheme.success;
      case 'closed':
        return AppTheme.gray600;
      default:
        return AppTheme.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final support = context.watch<SupportProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.myTickets,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ContactUsScreen()),
        ),
        backgroundColor: AppTheme.orange500,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          loc.newTicket,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
        ),
      ),
      body: _buildBody(loc, support),
    );
  }

  Widget _buildBody(AppLocalizations loc, SupportProvider support) {
    if (support.ticketsLoading && support.tickets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (support.ticketsError != null && support.tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.ticketsLoadFailed,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.read<SupportProvider>().fetchTickets(),
                child: Text(loc.retry, style: const TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        ),
      );
    }

    if (support.tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.support_agent_outlined,
                  size: 56, color: AppTheme.orange300),
              const SizedBox(height: 16),
              Text(
                loc.noTicketsYet,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<SupportProvider>().fetchTickets(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: support.tickets.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final ticket = support.tickets[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppTheme.roundedLg,
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ticket.subject,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _StatusChip(
                      label: loc.ticketStatus(ticket.status),
                      color: _statusColor(ticket.status),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '#${ticket.id} · ${_formatDate(ticket.createdAt)}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
