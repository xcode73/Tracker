# Tracker - Habit Tracking iOS App

<p align="center">
<img src="https://github.com/user-attachments/assets/6f2f13fd-d595-4a52-9f53-fc42e5a1b200" alt="Tracker List" width="188" height="406 style="margin-right: 10px;">
<img src="https://github.com/user-attachments/assets/322935b2-c6ea-4d47-b0c3-e66b0864b88b" alt="Tracker List" width="188" height="406">
</p>

## Links

[Design in Figma](https://www.figma.com/file/gONgrq8Q5PfEs1LUo7KX4h/Tracker?type=design&node-id=0-1&mode=design)

## Purpose and Goals

Tracker helps users build and maintain positive habits by tracking their completion over time.

### App objectives:

- Monitor habits on a weekly basis;
- View progress for each habit.

## Features Overview

- Users can create tracker cards, specifying a name, category, and schedule. They can also assign an emoji and color for differentiation.
- Cards are organized by categories, searchable, and filterable.
- A calendar allows users to view scheduled habits for a specific day.
- The app provides statistics on user performance, tracking progress and averages.

## Minimum Requirements

- Supports iPhone X and later, including adaptation for iPhone SE. Minimum iOS version: 13.4.
- Xcode 16.
- Uses iOS system font – SF Pro.
- Core Data is used for habit storage.

## Onboarding

On the first launch, the user is presented with an onboarding screen.

### Onboarding screen includes:

1. Splash screen;
2. Title and subtitle;
3. Page controls;
4. "Wow, technology!" button.

### Interactions:

- Users can swipe left or right to navigate pages, updating the page controls accordingly.
- Tapping the "Wow, technology!" button directs the user to the main screen.

## Creating a Habit Tracker

On the main screen, users can create a tracker for a habit or an irregular event. A habit is a recurring event, while an irregular event is not bound to specific days.

### Habit Tracker Creation Screen

- Screen title;
- Tracker name input field;
- Category section;
- Schedule settings;
- Emoji selection;
- Color selection;
- "Cancel" button;
- "Create" button.

### Irregular Event Tracker Creation Screen

- Screen title;
- Tracker name input field;
- Category section;
- Emoji selection;
- Color selection;
- "Cancel" button;
- "Create" button.

### Interactions:

- Users can create either a habit or an irregular event.
- The tracker name input field:
  - Shows a clear button after entering one character;
  - Has a 38-character limit with an error message if exceeded.
- The category selection screen allows users to:
  - View previously added categories;
  - Add new categories;
  - Select a category (marked with a blue checkmark).
- Habit creation includes a schedule selection:
  - Users can toggle weekdays for repetition;
  - Selected days appear under the schedule section.
- Users can select an emoji and a color.
- "Cancel" aborts creation; "Create" becomes active only when all fields are completed.

## Main Screen

The main screen displays all created trackers for the selected date, allowing users to edit or check statistics.

### Main Screen Elements

- "+" button to add a new tracker;
- "Trackers" title;
- Current date;
- Search bar;
- Tracker cards by category, showing:
  - Emoji;
  - Tracker name;
  - Days completed;
  - Completion button.
- "Filter" button;
- Tab bar.

### Interactions:

- "+" opens a menu for creating a habit or irregular event.
- Selecting a date opens a calendar to navigate between months.
- Users can search for trackers by name.
- Filters include:
  - "All trackers"
  - "Trackers for today"
  - "Completed trackers"
  - "Uncompleted trackers"
- Users can scroll to browse trackers.
- Tapping a card blurs the background and opens a modal window with options to:
  - Pin the tracker (moving it to a "Pinned" category);
  - Edit the tracker (same functionality as creation);
  - Delete the tracker (confirmation required).
- The tab bar allows navigation between "Trackers" and "Statistics."

## Editing and Deleting Categories

During tracker creation, users can edit or delete categories.

### Interactions:

- Long-pressing a category opens a modal with options to:
  - Edit the category name;
  - Delete the category (confirmation required).

## Viewing Statistics

The statistics tab provides insights into progress and achievements.

### Statistics Screen Elements

- "Statistics" title;
- List of statistics, each showing:
  - A numerical value;
  - A label.
- Tab bar.

### Displayed Statistics:

- **Best Streak**: Maximum consecutive days of habit completion.
- **Perfect Days**: Days when all scheduled habits were completed.
- **Completed Trackers**: Total completed habits.
- **Average Value**: Average daily habit completion.

### Interactions:

- If no data is available, a placeholder appears.
- If at least one metric has data, statistics are displayed with zero values where applicable.

## Dark Mode

The app supports dark mode, adapting to system settings.
