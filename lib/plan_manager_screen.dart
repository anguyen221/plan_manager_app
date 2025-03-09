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
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  void _openCreatePlanModal({Plan? planToEdit}) {
    if (planToEdit != null) {
      nameController.text = planToEdit.name;
      descriptionController.text = planToEdit.description;
      dateController.text = planToEdit.date;
    } else {
      nameController.clear();
      descriptionController.clear();
      dateController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(planToEdit != null ? 'Edit Plan' : 'Create New Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Plan Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Date'),
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
                  if (planToEdit != null) {
                    planToEdit.name = nameController.text;
                    planToEdit.description = descriptionController.text;
                    planToEdit.date = dateController.text;
                  } else {
                    plans.add(Plan(
                      name: nameController.text,
                      description: descriptionController.text,
                      date: dateController.text,
                      isCompleted: false,
                    ));
                  }
                });
                nameController.clear();
                descriptionController.clear();
                dateController.clear();
                Navigator.of(context).pop();
              },
              child: Text(planToEdit != null ? 'Update' : 'Create'),
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
                    onLongPress: () {
                      _openCreatePlanModal(planToEdit: plans[index]);
                    },
                    onDoubleTap: () {
                      setState(() {
                        plans.removeAt(index);
                      });
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
        onPressed: () => _openCreatePlanModal(),
        tooltip: 'Create Plan',
        child: Icon(Icons.add),
      ),
    );
  }
}
