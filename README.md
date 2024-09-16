# Demonstration of async validation in Flutter with FormBuilder.

_May this save you time, Dear Reader, for I burned way too many hours on it._

## Intro

Say you are building a cross-platform app in Flutter, and you have a form.

You will quickly stumble upon the [flutter_form_builder][0] package, which will
give you a [FormBuilder][1], and its related [form_builder_validators][2]
which is what it says on the tin.

The good news: this handles standard validation really well and generally
makes it easy to build normal-looking forms with the Material look, Material
being by far the best-supported UI kit in Flutter (for obvious reasons).

The bad news: form field validators are synchronous! (And not just here, but
in Flutter generally.)

This matters because you often have something like, say, a username, which
you will want to check against some API.  But the only supported means of
doing that is the asynchronous [http][3] package!

It turns out this is not _so_ hard to do, even if it's [kludgey][4] enough to
leave one scratching one's head about why it's not just a standard feature of
Flutter forms. Anyone? [Anyone?][5]

## The solution (so far)

1. Keep a state variable tracking when you're awaiting the async operation.
2. Update that exclusively in a [SetState][6] call, so you can:
3. Render your form differently if you are async-ing or not.
4. Make the async call in your `onPressed` handler, which can be async.
5. Profit!!!

## Extras

Having dabbled in Rust a bit, I came to really like the "error or success"
[Result][7] type.  Instead of rolling my own, I decided to try out the
[fpdart][8] package, which despite some documentation weakness seems to be
the community favorite these days.

I ended up with code like this for looking up ChatGPT models:

```dart
final modelsEither = await fetchOpenAIModels(baseUrl, apiKey);
modelsEither.match(
  (ApiError error) {
    final cause = error.cause;
    debugPrint('ERROR $error $cause');
    if (error is ApiInvalidKeyError) {
      _formKey.currentState?.fields['api_key']
          ?.invalidate('$cause');
    } else {
      _formKey.currentState?.fields['api_url']
          ?.invalidate('$cause');
    }
  },
  (List<String> models) {
    print('MODELS $models');
    // AND NOW, DO STUFF...
  },
);
```

On the one hand, I find this preferable to `try/catch` and type-checking the
error.  On the other hand, I also found it confusing enough that I have left
it out of this demo.

## Why not...

### `sync_http`

1. It's [broken][9].
2. Google probably won't fix it and nobody else will either.
3. Even if it worked, it would be a bad idea in an app because...
4. Sync blocks the UI.

### `someFutureThing.then(...)`

You still have to put all the async logic into your `then`, the only upside
is you can call it in a function that is not marked async.

### Various other hacks to pretend async code is sync code.

Well, as noted above, it's Probably A Bad Idea.  Certainly worse than the
solution here.

Also, to be fair: despite the, er, documentation defecit in the Flutter
ecosystem and the *correctness* deficit on Google's end, doing `sync_foo` in
a cross-platform framework is a massive liability.

What are you supposed to do when the bosses tell you to build it for "web?"

## RFC

I'm putting this out there as a public service, but also because I will
probably need to remember it myself some day.  If you find anything wrong,
or have any suggestions, please feel free open an "Issue" here.

And as long as you're here, have a look at some [art][10]!

Cheers

_-- frosty_

---

```END```

<!-- links -->
[0]: https://pub.dev/packages/flutter_form_builder
[1]: https://pub.dev/documentation/flutter_form_builder/latest/flutter_form_builder/FormBuilder-class.html
[2]: https://pub.dev/packages/form_builder_validators
[3]: https://pub.dev/packages/http
[4]: https://en.wikipedia.org/wiki/Kludge
[5]: https://x.com/sundarpichai
[6]: https://api.flutter.dev/flutter/widgets/State/setState.html
[7]: https://doc.rust-lang.org/std/result/
[8]: https://pub.dev/packages/fpdart
[9]: https://github.com/google/sync_http.dart/issues/25#issuecomment-2353049278
[10]: https://kevinfrost.com/
