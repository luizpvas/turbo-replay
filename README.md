# `turbo-replay`

`turbo-replay` caches and assigns a sequence number to broadcasted messages. When a client loses
a message because of flaky network, we're able to resend (or replay, hence the name :smile:) missed
events in the same order they were originally sent.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "turbo-replay"
```

Execute the following commands to install the gem and generate an initializer:

```bash
$ bundle install
$ bundle exec turbo-replay:install
```

Replace the import for `@hotwired/turbo-rails` in your application.js

```js
- import "@hotwired/turbo-rails"
+ import "turbo-replay"
```

Now reload your server and that's it!

### How does it work?

`turbo-replay` intercepts broadcast calls and stores messages in a cache. Each message is assigned
a `sequence_number`. This value is unique per channel.

Because `sequence_number` is sequential, clients knows what the next value is expected to be.
If an arrived `sequence_number` don't match the expected value, it means they missed a message.

> The `sequence_number` ensures that we can detect missed messages even without a disconnect event.

When the client notices they missed an event, they ask the server to resend (or replay, hence the name)
messages after the last known `sequence_number`.

### I broadcast a lot of stuff, isn't the cache this too expensive?

Maybe, depends on your use case. You have two controls over the retention: time and size.
Take a look at `config/initializers/turbo_replay.rb` to tweak the retention.

### What if the client stays offline too long?

There's nothing we can do if the client's latest received message is older than the oldest message in the cache.

That's what we call **unrecoverable**.

We emit an event so you can implement a custom handler for that case:

```js
window.addEventListener('turbo-replay:unrecoverable', () => {
  console.log("You're offline for too long. Please reload the page.")
})
```
## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
