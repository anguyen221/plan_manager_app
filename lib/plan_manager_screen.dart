import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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

  DateTime selectedDate = DateTime.now();

  Map<DateTime, List<Plan>> plansByDate = {};

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
      body: Column(
        children: [
          DragTarget<Plan>(
            onAcceptWithDetails: (dragDetails) {
              setState(() {
                Plan draggedPlan = dragDetails.data;
                draggedPlan.date = selectedDate.toString().split(' ')[0];
                if (plansByDate[selectedDate] == null) {
                  plansByDate[selectedDate] = [];
                }
                plansByDate[selectedDate]!.add(draggedPlan);
              });
            },
            builder: (context, candidateData, rejectedData) {
              return TableCalendar(
                focusedDay: selectedDate,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, focusedDay) {
                    List<Plan> plansForDay = plansByDate[date] ?? [];
                    return Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: focusedDay == date ? Colors.blue.shade100 : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${date.day}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              children: plansForDay
                                  .map((plan) => Text(
                                        plan.name,
                                        style: TextStyle(fontSize: 12, color: Colors.blue),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                return Draggable<Plan>(
                  data: plans[index],
                  feedback: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.blueAccent,
                      child: Text(plans[index].name, style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  childWhenDragging: Container(),
                  child: GestureDetector(
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreatePlanModal(),
        tooltip: 'Create Plan',
        child: Icon(Icons.add),
      ),
    );
  }
}
