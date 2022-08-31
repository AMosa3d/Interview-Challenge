# Interview-Challenge
## About The Project
## Tools used
## Installation and Run
## Agile Process
The Agile process used here is very simple as there is only one developer, it shouldn't be complicated at all.

This has been done simply using Clickup as the board management tool:
- The Challange itself has been separated into mini-tasks.
- Each task has simply 3 statuses (TODO, In Progress, Completed), acceptance criteria, time-estimation and due-date, also comments if needed.
- The tasks hasn't been written as a user-stories, it was much simpler and better to be segregatted as a technical-based stories that fits with the challenge target.

If you are interested, you can check the board's **[List view](https://sharing.clickup.com/42008161/l/h/6-222229294-1/ef602d4c6f6412b)**, it also has a **[Gantt-Chart view](https://sharing.clickup.com/42008161/g/h/181zk1-20/6ed8fc490596066)**.

![Clickup Board List View](/assets/imgs/docs/agile_board_process.png "Clickup Board List View")
## Covered points
## Documentation
### API Documentation
### Database Design
For the core data of the system that holds everything together, MYSQL is the bigman here.

We've 3 main tables:
- **Applications Table**:
  - `name`: Given by the client and there is no restriction to its uniqueness.
  - `token`: Generated **unique JWT token**.
  - `chats_count`: Aggregated value of the number of chats that are related to this application.
- **Chats Table**:
  - `number`: Each chat has a number that the user uses to reach that chat, it's not the id of the table and it's only **unique per application**.
  - `token`: Generated **unique JWT token**.
  - `messages_count`: Aggregated value of the number of messages that are related to this chat.
- **Messages Table**:
  - `number`: Same as in the chat table but **unique per chat**.
  - `body`: The sent message body in the chat.

There is the Database Schema to fully visualize everything together: 

![MySQL Database Design](/assets/imgs/docs/mysql_database_design.png "MySQL Database Design")

### Integration and Configuration Steps
### Git-flow used
