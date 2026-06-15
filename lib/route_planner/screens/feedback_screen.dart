import 'package:flutter/material.dart';
import '../services/feedback_service.dart';
import 'add_report_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FeedbackService _service = FeedbackService();

  List<dynamic> incidents = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await _service.getNearbyIncidents();
    setState(() {
      incidents = data;
      loading = false;
    });
  }

  Future<void> upvote(String id) async {
    await _service.verifyIncident(id);
    loadData(); // refresh after vote
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text("Live Incidents"),
  backgroundColor: Colors.blue,
  actions: [
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddReportScreen(),
          ),
        );
      },
    )
  ],
),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final item = incidents[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(item['title']),
                    subtitle: Text(item['category']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${item['upvotes']}"),
                        IconButton(
                          icon: const Icon(Icons.thumb_up),
                          onPressed: () => upvote(item['id']),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}