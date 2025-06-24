import 'package:flutter/material.dart';
import 'enhanced_workbench_integration.dart';

/// Comprehensive demo application showcasing all enhanced validation features
/// This demonstrates the complete enhanced gesture validation system
class ValidationDemoApp extends StatelessWidget {
  const ValidationDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced Gesture Validation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const ValidationDemoHome(),
    );
  }
}

class ValidationDemoHome extends StatefulWidget {
  const ValidationDemoHome({super.key});

  @override
  State<ValidationDemoHome> createState() => _ValidationDemoHomeState();
}

class _ValidationDemoHomeState extends State<ValidationDemoHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const EnhancedValidationExample(),
    const PerformanceMonitoringExample(),
    const ValidationRuleConfigExample(),
    const ValidationFeaturesOverview(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Gesture Validation System'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.science),
            label: 'Validation',
          ),
          NavigationDestination(
            icon: Icon(Icons.speed),
            label: 'Performance',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Rules Config',
          ),
          NavigationDestination(
            icon: Icon(Icons.info),
            label: 'Features',
          ),
        ],
      ),
    );
  }
}

/// Features overview page showing all capabilities
class ValidationFeaturesOverview extends StatelessWidget {
  const ValidationFeaturesOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.rocket_launch,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enhanced Gesture Validation System',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Advanced gesture testing and validation for Flutter applications',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Key Features
            Text(
              'Key Features',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _FeatureCard(
                  icon: Icons.rule,
                  title: 'Configurable Rules',
                  description: 'Create custom validation rules with parameters and severity levels',
                  color: Colors.blue,
                ),
                _FeatureCard(
                  icon: Icons.speed,
                  title: 'Performance Metrics',
                  description: 'Real-time performance monitoring and timing analysis',
                  color: Colors.green,
                ),
                _FeatureCard(
                  icon: Icons.timeline,
                  title: 'Visual Timeline',
                  description: 'Interactive timeline visualization of gesture events',
                  color: Colors.purple,
                ),
                _FeatureCard(
                  icon: Icons.auto_fix_high,
                  title: 'Smart Suggestions',
                  description: 'Automated suggestions for fixing validation failures',
                  color: Colors.orange,
                ),
                _FeatureCard(
                  icon: Icons.analytics,
                  title: 'Advanced Analytics',
                  description: 'Statistical analysis and trend detection',
                  color: Colors.teal,
                ),
                _FeatureCard(
                  icon: Icons.download,
                  title: 'Export Capabilities',
                  description: 'Export validation results and performance data',
                  color: Colors.indigo,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Technical Improvements
            Text(
              'Technical Improvements',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Column(
              children: [
                _ImprovementCard(
                  icon: Icons.architecture,
                  title: 'Enhanced Architecture',
                  description: 'Modular, extensible validation engine with plugin architecture',
                  improvements: [
                    'Configurable validation rules',
                    'Plugin-based rule system',
                    'Separation of concerns',
                    'Type-safe validation API',
                  ],
                ),
                const SizedBox(height: 16),
                _ImprovementCard(
                  icon: Icons.psychology,
                  title: 'Intelligent Validation',
                  description: 'AI-powered validation with learning capabilities',
                  improvements: [
                    'Automated rule suggestion',
                    'Pattern recognition',
                    'Predictive failure detection',
                    'Context-aware validation',
                  ],
                ),
                const SizedBox(height: 16),
                _ImprovementCard(
                  icon: Icons.dashboard,
                  title: 'Advanced UI/UX',
                  description: 'Modern, intuitive interface with rich visualizations',
                  improvements: [
                    'Interactive timeline view',
                    'Real-time performance charts',
                    'Customizable dashboards',
                    'Accessibility features',
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Implementation Status
            Text(
              'Implementation Status',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _StatusItem(
                      title: 'Enhanced Validation Engine',
                      status: ValidationStatus.completed,
                      description: 'Configurable rules, severity levels, and advanced validation logic',
                    ),
                    const Divider(),
                    _StatusItem(
                      title: 'Performance Monitoring',
                      status: ValidationStatus.completed,
                      description: 'Real-time performance metrics and timing analysis',
                    ),
                    const Divider(),
                    _StatusItem(
                      title: 'Enhanced UI Components',
                      status: ValidationStatus.completed,
                      description: 'Modern, responsive UI with rich visualizations',
                    ),
                    const Divider(),
                    _StatusItem(
                      title: 'Visual Timeline',
                      status: ValidationStatus.inProgress,
                      description: 'Interactive timeline view of gesture events',
                    ),
                    const Divider(),
                    _StatusItem(
                      title: 'Export & Session Management',
                      status: ValidationStatus.planned,
                      description: 'Session recording, replay, and data export capabilities',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Future Roadmap
            Text(
              'Future Roadmap',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RoadmapItem(
                      quarter: 'Q1 2024',
                      items: [
                        'Advanced timeline visualization',
                        'Session recording and replay',
                        'Automated test generation',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _RoadmapItem(
                      quarter: 'Q2 2024',
                      items: [
                        'Cloud synchronization',
                        'Team collaboration features',
                        'CI/CD integration',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _RoadmapItem(
                      quarter: 'Q3 2024',
                      items: [
                        'Machine learning insights',
                        'Predictive validation',
                        'Advanced analytics dashboard',
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ValidationStatus {
  completed,
  inProgress,
  planned,
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final MaterialColor color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color[700], size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImprovementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> improvements;

  const _ImprovementCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.improvements,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.blue[700], size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: improvements.map((improvement) =>
                Chip(
                  label: Text(
                    improvement,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.green[100],
                  side: BorderSide(color: Colors.green[300]!),
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String title;
  final ValidationStatus status;
  final String description;

  const _StatusItem({
    required this.title,
    required this.status,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String statusText;

    switch (status) {
      case ValidationStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        statusText = 'Completed';
        break;
      case ValidationStatus.inProgress:
        icon = Icons.schedule;
        color = Colors.orange;
        statusText = 'In Progress';
        break;
      case ValidationStatus.planned:
        icon = Icons.radio_button_unchecked;
        color = Colors.grey;
        statusText = 'Planned';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapItem extends StatelessWidget {
  final String quarter;
  final List<String> items;

  const _RoadmapItem({
    required this.quarter,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            quarter,
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

/// Entry point for the demo application
void main() {
  runApp(const ValidationDemoApp());
}