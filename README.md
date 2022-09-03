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
For the documentation, I have integrated Swagger with the most simplest and fastest way as the time of the challenge is limited and I wanted to it to be a little bit neat.

The Api documentation can be accessed -without authentication to keep it simple- after running the rails server at `localhost:3000/api-docs`

Here is a sample screenshot:
![Swagger Api Documentation](/assets/imgs/docs/api_documentation.png "Swagger Api Documentation")

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
  - Both `number` & `application_id` are unique as a group, since we can't have 2 chats with the same number in the same application.
- **Messages Table**:
  - `number`: Same as in the chat table but **unique per chat**.
  - `body`: The sent message body in the chat.
  - Both `number` & `chat_id` are unique as a group, since we can't have 2 messages with the same number in the same chat.

There is the Database Schema to fully visualize everything together:

![MySQL Database Design](/assets/imgs/docs/mysql_database_design.png "MySQL Database Design")

### Code Documentation
#### Generated Token of the Application
I was debating about using **JSON Web Token (JWT)**, **UUID** or any randomly generated string, so I thought that using **randomly generate 32 hex chars length string** would be the best here as used below.
```ruby
def generate_token
    self.token = loop do
      generatedToken = SecureRandom.hex(32)
      break generatedToken unless Application.exists?(token: generatedToken)
    end
end
```
As you can see it's very simple and serves the requirement given but there is 2 important notes that should be discussed here:
  1. This randomly string is not guaranteed to be unique but it is handled by unique index in MySQL and ```unless Application.exists?(token: generatedToken)``` . This requires a db read operation to confirm and in a very raaaare cases would require more than one read. (as num of possible tokens = 16 hex char ^ 32 max len).
  2. We would handle uniqueness better in JWT but requires more effort to build its parameters and generate it. Although we would need to use the ID of the application to guarantee its uniqueness which would require also a db read operation, but there are cache hacks that Redis can assist in to make it smoother.

The reason why I have ignored using JWT was that I tried to make it simple and the application table read/writes operations is not the main hassle and additional read for the current scale is fair enough.


### Git-flow used

### ElasticSearch
Here it was very fun with a lot of debates and I had many decisions to take based on the time-limit of the task, the scale of the program and the given requirements.

The hassle was, 'Should I save the data only in ElasticSearch or duplicate the important data of the search feature in ElasticSearch?'.

Here is what I have reached:
- ElasticSearch is a very powerful search engine and it can store data, but it shouldn't be the primary database. As if it was down, we only lose the search functionality of the app, not all the functionalities. SO it's better to work in sync with the primary database **(our single source of truth)**.
- The data should be kept in ElasticSearch itself to be queried, and since MySQL is the primary database. I should always sync the data between MySQL and ElasticSearch. There was many apporaches but I decided to do it with each CRUD operation, and also it would be fun to integrate Logstash to do all the data sync but the time was very limited to do so.
- There was no need to sustain any data from any other table but ```messages``` table.
- The approach I have used is very simple, but it has a drawback as I doesn't handle failed CRUDs on Elastic which will lead to data inconsistency, so that's why I would rather go with Logstash if I had more time.
- The data structure of the **Document** that is saved inside the Elastic **Index** is the same as in MySQL as the data we have is very simple and should be both here and there.
- I also didn't need to use ```as_indexed_json``` and ```mapping``` as the defaults are doing pretty what was given as a requirement, so no need to show off or over-engineering.

The Elastic search query finds any message that its body have one or more word in any order, declining the given order. I've also played with RegExp to build a **Partial Search Mechanism** but I have rolled it back as it sustains the order, so I preferred passing multiple words without constraining the order of the search query. Here you can find it:
```ruby
searchBody = {
  query: {
    bool: {
      must: [
        {
          term: {
            chat_id: chatId
          }
        },
        match: {
          body: searchQuery
        }
      ]
    }
  }
}
```

And this is a sample of the data using **Kibana** dashboard:
![Kibana Dashboard](/assets/imgs/docs/kibana_dashboard_sample_data.png "Kibana Dashboard")
