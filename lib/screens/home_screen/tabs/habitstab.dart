import 'package:flutter/material.dart';
import 'package:productivity_app/models/habit.dart';
import 'package:productivity_app/screens/habit/add_edit_habit_page.dart';
import 'package:productivity_app/screens/habit/habit_details_page.dart';
import 'package:productivity_app/services/database.dart';
import 'package:productivity_app/services/local_notification.dart';
import 'package:productivity_app/utils/extensions.dart';

class HabitsTab extends StatefulWidget {
  const HabitsTab(
      {super.key,
      required this.habitsStream,
      required this.isCurrent,
      required this.searchText});

  final Stream<List<Habit>> habitsStream;
  final bool isCurrent;
  final String searchText;

  @override
  State<HabitsTab> createState() => _HabitsTabState();
}

class _HabitsTabState extends State<HabitsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final today = DateTime.now();
    final searching = widget.isCurrent && widget.searchText.trim().isNotEmpty;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: addHabit,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Habit>>(
        stream: widget.habitsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allHabits = snapshot.data!;
          if (allHabits.isEmpty) {
            return Center(
              child:
                  Text(searching ? "No match found" : "No Habits added yet!"),
            );
          }

          final query = widget.searchText.trim().toLowerCase();
          final List<Habit> habits = searching
              ? allHabits.where((habit) {
                  final title = habit.title?.toLowerCase() ?? "";
                  final description = habit.description?.toLowerCase() ?? "";
                  return title.contains(query) || description.contains(query);
                }).toList()
              : List<Habit>.from(allHabits);

          if (habits.isEmpty) {
            return const Center(child: Text("No match found"));
          }

          // Global time-based sorting before splitting into sections.
          // - null time is treated as 00:00 and ordered before explicit 00:00.
          habits.sort((a, b) {
            final aHasTime = a.time != null;
            final bHasTime = b.time != null;
            final aMinutes = (a.time?.hour ?? 0) * 60 + (a.time?.minute ?? 0);
            final bMinutes = (b.time?.hour ?? 0) * 60 + (b.time?.minute ?? 0);

            if (aMinutes != bMinutes) return aMinutes.compareTo(bMinutes);
            if (aHasTime != bHasTime) return aHasTime ? 1 : -1;

            final aTitle = (a.title ?? "").toLowerCase();
            final bTitle = (b.title ?? "").toLowerCase();
            return aTitle.compareTo(bTitle);
          });

          final (completed, remaining, others) =
              (<Habit>[], <Habit>[], <Habit>[]);
          for (Habit habit in habits) {
            /// true means should be disabled
            final isBefore =
                today.toDateOnly().isBefore(habit.startDate!.toDateOnly());
            final isCompleted = habit.completedDate != null &&
                today
                    .toDateOnly()
                    .isAtSameMomentAs(habit.completedDate!.toDateOnly());

            if (isBefore) {
              others.add(habit);
            } else if (isCompleted) {
              completed.add(habit);
            } else {
              remaining.add(habit);
            }
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
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
              SliverPadding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height / 3),
              ),
            ],
          );
        },
      ),
    );
  }

  void addHabit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddEditHabitPage(habit: Habit(), isEditMode: false),
      ),
    );
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HabitDetailsPage(habit: habit),
            ));
      },
      child: Container(
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
                  ? () async {
                      await LocalNotification.flutterLocalNotificationsPlugin
                          .cancel(id: habit.id!.hashCode);
                      await LocalNotification.setHabitNotification(habit,
                          scheduleOnly: true);
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
      ),
    );
  }
}
