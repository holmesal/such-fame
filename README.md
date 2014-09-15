Just a little profile app to play around with famo.us.

Impressions so far:

* ScrollViews are pretty shitty in Famous core right now. They can't auto-size child Surfaces with dynamic content, so you have to patch core to get this to work out. Which breaks parent Modifiers. It's a mess.
* There seems to be some inconsistent `fa-properties` and `fa-options` bindings between Surfaces, ContainerSurfaces, and Modifiers.
* Adding an `ng-if` on the first of several consecutive views can cause it to be rendered after the subsequent views, unless all views have an `ng-if` on them.
