import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Manager App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlanManagerScreen(),
    );
  }
}

class Plan {
  String name;
  String description;
  String date;
  bool isCompleted;

  Plan({required this.name, required this.description, required this.date, this.isCompleted = false});
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];

  void _openCreatePlanModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Plan Name'),
                onChanged: (value) {},
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {},
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Date'),
                onChanged: (value) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  plans.add(Plan(
                    name: 'New Plan',
                    description: 'Description of the plan',
                    date: '2025-03-10',
                    isCompleted: false,
                  ));
                });
                Navigator.of(context).pop();
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan Manager App'),
      ),
      body: Center(
        child: plans.isEmpty
            ? Text('No plans available.')
            : ListView.builder(
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! < 0) {
                        setState(() {
                          plans[index].isCompleted = true;
                        });
                      }
                    },
                    child: ListTile(
                      title: Text(plans[index].name),
                      subtitle: Text('${plans[index].description} - ${plans[index].date}'),
                      tileColor: plans[index].isCompleted ? Colors.green : Colors.yellow,
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePlanModal,
        tooltip: 'Create Plan',
        child: Icon(Icons.add),
      ),
    );
  }
}
