import 'package:flutter/material.dart';
import 'package:productivity_app/models/habit.dart';
import 'package:productivity_app/screens/habit/add_habit_page.dart';
import 'package:productivity_app/services/database.dart';
import 'package:productivity_app/utils/extensions.dart';

class HabitsTab extends StatefulWidget {
  const HabitsTab({Key? key}) : super(key: key);

  @override
  State<HabitsTab> createState() => _HabitsTabState();
}

class _HabitsTabState extends State<HabitsTab> {
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: addHabit,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Habit>>(
        stream: DatabaseService.getHabits(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final habits = snapshot.data!;
          if (habits.isEmpty) {
            return const Center(child: Text("No Habits added yet!"));
          }
          final (completed, remaining, others) =
              (<Habit>[], <Habit>[], <Habit>[]);
          for (Habit habit in habits) {
            /// true means should be disabled
            final isBefore =
                today.toDateOnly().isBefore(habit.startDate!.toDateOnly());
            final isCompleted = habit.lastCompletionHistory != null &&
                today.toDateOnly().isAtSameMomentAs(
                    habit.lastCompletionHistory!.time!.toDateOnly());

            if (isBefore) {
              others.add(habit);
            } else if (isCompleted) {
              completed.add(habit);
            } else {
              remaining.add(habit);
            }
          }

          return CustomScrollView(
            slivers: [
              if (remaining.isNotEmpty) ...[
                const SliverPadding(
                  padding: EdgeInsets.only(left: 10.0, top: 10.0),
                  sliver: SliverToBoxAdapter(
                    child: Text("Remaining for today"),
                  ),
                ),
                SliverList.builder(
                  itemCount: remaining.length,
                  itemBuilder: (context, index) => HabitCard(
                      habit: remaining[index],
                      isEnabled: true,
                      isCompleted: false),
                ),
              ],
              if (completed.isNotEmpty) ...[
                const SliverPadding(
                  padding: EdgeInsets.only(left: 10.0, top: 10.0),
                  sliver: SliverToBoxAdapter(
                    child: Text("Done for today"),
                  ),
                ),
                SliverList.builder(
                  itemCount: completed.length,
                  itemBuilder: (context, index) => HabitCard(
                      habit: completed[index],
                      isEnabled: true,
                      isCompleted: true),
                ),
              ],
              if (others.isNotEmpty) ...[
                const SliverPadding(
                  padding: EdgeInsets.only(left: 10.0, top: 10.0),
                  sliver: SliverToBoxAdapter(
                    child: Text("Others"),
                  ),
                ),
                SliverList.builder(
                  itemCount: others.length,
                  itemBuilder: (context, index) => HabitCard(
                      habit: others[index],
                      isEnabled: false,
                      isCompleted: false),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> addHabit() async {
    final data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddHabitPage(),
      ),
    );
    if (data != null) {
      final habit = Habit(
        title: data["title"],
        description: data["description"],
        currentStreak: 0,
        highestStreak: 0,
        startDate: data["startDate"],
        endDate: data["endDate"],
      );
      DatabaseService.saveHabit(habit).then((value) => habit.id = value);
    }
  }
}

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.isEnabled,
    required this.isCompleted,
  });

  final Habit habit;
  final bool isEnabled;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey, width: 0.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                habit.title!,
                style: const TextStyle(fontSize: 20),
              ),
              Text('Streak: ${habit.currentStreak}')
            ],
          ),
          IconButton(
            onPressed: isEnabled && !isCompleted
                ? () {
                    DatabaseService.addHabitHistory(habit, null);
                  }
                : null,
            icon: Icon(
              isCompleted ? Icons.check_circle_outline : Icons.done,
              color: isCompleted ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
