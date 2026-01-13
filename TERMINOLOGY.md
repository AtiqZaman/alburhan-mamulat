# Alburhan Mamulat - Islahi Terminology

## Correct Islamic Terminology

### Users
- **مربی (Murabbī)** = Spiritual Guide/Mentor/Teacher
  - Assigns daily tasks to Salikeens
  - Reviews daily updates
  - Approves level progression

- **سالک (Sālik)** = Spiritual Seeker/Student/Disciple
  - Completes assigned tasks
  - Submits daily updates
  - Progresses through levels

### System Structure
- **40-Day Cycles**: Each level is based on 40-day spiritual practice period (Islahi concept)
- **Task Management**: Daily spiritual tasks assigned by Murabbī to Sālik
- **Progress Tracking**: Daily updates showing task completion
- **Level Progression**: After completing 40 days at one level, advance to next

## App Roles

1. **Admin** (ایڈمن)
   - Manages system
   - Adds Murabbīs
   - Adds Sālikīs (plural of Sālik)
   - Sets up levels and tasks

2. **Murabbī** (مربی)
   - Spiritual guide
   - Assigns and manages tasks
   - Reviews daily updates from assigned Sālikīs
   - Approves level progression

3. **Sālik** (سالک)
   - Student/seeker
   - Completes daily tasks
   - Submits updates
   - Progresses through levels

## Database Collections

- `users` - Stores user profiles with role field ('murabi', 'salik', 'admin')
- `tasks` - Stores task definitions by level
- `dailyUpdates` - Tracks daily task completion by Sālikīs
- `levels` - Stores level configurations

## UI Labels (Corrected)

| English | Urdu | Context |
|---------|------|---------|
| Total Murabbīs | کل مربی | Admin Dashboard |
| Total Sālikīs | کل سالکین | Admin Dashboard |
| Add Murabbī | مربی شامل کریں | Admin Dashboard |
| Add Sālik | سالک شامل کریں | Admin Dashboard |
| My Sālikīs | میرے سالکین | Murabbī Dashboard |
| Select Murabbī | مربی منتخب کریں | Add Sālik Form |
| Murabbī Dashboard | مربی ڈیش بورڈ | Header |

This app is designed to facilitate Islamic spiritual development (Islahi) through structured mentorship.
