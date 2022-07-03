# turbo-replay

**turbo-replay** assigns a sequence number to broadcasted messages and caches them. When a client 
disconnects because of flaky network, we're able to resend (or replay, hence the name) missed
messages in the same order they were originally sent.

## Installation

> **Important**: Make sure you have installed [`hotwired/turbo-rails`](https://github.com/hotwired/turbo-rails) before using this gem!

Add this line to your application's Gemfile:

```ruby
gem "turbo-replay"
```

Execute the following commands to install the gem and generate an initializer:

```bash
$ bin/bundle install
$ bin/rails turbo-replay:install
```

Replace the import for `@hotwired/turbo-rails` in your application.js

```diff
- import "@hotwired/turbo-rails"
+ import "turbo-replay"
```

Now reload your server - and that's it!

### Javascript events

```javascript
// The user connected for the first time to a channel.
window.addEventListener('turbo-replay:connected', (ev) => {
  console.log('connected', ev.detail.channel)
})

// The user disconnected from a channel and we're retrying to reconnect.
// It's good to show some 'reconnecting...' indication here.
window.addEventListener('turbo-replay:disconnected', (ev) => {
  console.log('disconnected', ev.detail.channel)
})

// The user reconnected after being offline a little bit.
// Hide the 'reconnecting...' indicationk here.
window.addEventListener('turbo-replay:reconnected', (ev) => {
  console.log('reconnected', ev.detail.channel)
})

// The user reconnected, but the latest received message was older
// than the oldest message in the cache. There's nothing we can do
// here to recover the state. You can reload the whole application
// or show some indication asking the user to reload.
window.addEventListener('turbo-replay:unrecoverable', (ev) => {
  console.log('unrecoverable', ev.detail.channel)
})
```

### How does it work?

**turbo-replay** stores broadcasted messages in a cache. Each message is assigned a sequence number.

Because the sequence number is sequential, clients know what the next value is expected to be.
If an arrived `sequence_number` doesn't match the expected value, it means the client missed a message.

> The sequence number ensures clients can detect missed messages even without a disconnect event.

When the client notices they missed an event, they ask the server to resend messages after the last known
sequence number.

### I like to broadcast lots of stuff, isn't the cache too much overhead?

Maybe, it depends on your use case. Take a look at `config/initializers/turbo_replay.rb` in your
application to tweak the cache's retention policy.

### What if the client stays offline too long?

There's nothing we can do if the client's latest received message is older than the oldest message in the cache.

Suggestion: handle the `turbo-replay:unrecoverable` event and display a message asking the user
to reload the app. For example:

```js
window.addEventListener('turbo-replay:unrecoverable', () => {
  window.alert("You're offline for too long. Please reload the page.")
})
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
