# Sleep Tracker API

This is a RESTful API for a sleep tracking application. It allows users to track their sleep, follow other users, and view their friends' sleep data.

## Features

* User creation and management
* Clock in and out to record sleep sessions
* Follow and unfollow other users
* View a paginated feed of friends' sleep data

## Requirements

* Docker
* docker-compose

## Run projects

To run project you should create new `.env` based on `.env.example`

```bash
cp .env.example .env
```

Then you can run docker container

```bash
docker compose up -d
```

## Performance Updates

Performance has been a key consideration during development. The following updates have been made to improve the API's performance:

* **Caching**: The application uses `Rails.cache.fetch` to cache sleep records in the `Api::V1::SleepsController`. The cache key is generated based on the current user, the action, and the page number. The cache expires in 5 minutes and has a race condition TTL of 60 seconds.

* **Database Indexes**: The `20250921173503_add_performance_indexes.rb` migration adds the following indexes to improve database performance:
  * An index on `follows` for `follower_id`, `follower_type`, `followable_id`, and `followable_type` to speed up queries on the `follows` table.
  * An index on `sleeps` for `created_at` to speed up sorting by creation time.
  * An index on `sleeps` for `duration` to speed up sorting by sleep duration.

* **Pagination**: The API uses the `pagy` gem to paginate results in the `Api::V1::SleepsController`. The `index` and `clock_in` actions both use `pagy` to limit the number of records returned to 10 per page. The pagination headers are then merged into the response.

* **Background Jobs**: The API uses the `ActiveJob` with `sidekiq` to process follow / unfollow users, since this process not require immediate feedback.

## Considerations

* Requirements to returns all user sleep records after committing clock in may not wise, because it still returns large amount of data and require additional computation to load the records. Considering this, user sleep records is moved to new endpoint `api/v1/users/:id/sleeps` with support of caching and pagination.
* Added `.with_lock` pessimistic lock in clock in/out endpoint, this may affecting performance but it helps data integrity to prevent race condition.
* Follow/Unfollow action does not require immediate feedback, so this process can be offloaded to the background jobs with discard capabilities when validation fails.

## Performance Testing with k6

This project uses [k6](https://k6.io/) for performance testing. The k6 test script is located at `k6/scripts/sleeps_index.js`.

To run the performance test, use the following command:

```bash
docker-compose -f docker-compose.k6.yml run k6
```

This will run a load test against the `api/v1/users/1/sleeps` endpoint. The test options are configured in the `k6/scripts/sleeps_index.js` file.
