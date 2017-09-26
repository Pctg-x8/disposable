Disposable
---

A disposing mechanism like `IDisposable` in C#, and using guard like `using` statement in C#.

## Examples

```d
class DisposableInt : Disposable
{
    private int v;
    private bool disposed;

    this(int t) { this.v = t; }
    /// Destructor must call `dispose` with `disposing = false` in its body
    ~this() { this.dispose(false); }

    override nothrow void dispose() { this.dispose(true); }
    nothrow void dispose(bool disposing)
    {
        assert(this.disposed != disposing);
        this.disposed = true;
    }
}

mixin(using!q{ auto p = new DisposableInt(2) });
static assert(is(typeof(p) == DisposableInt));
mixin(using!q{ DisposableInt di = new DisposableInt(2) });
mixin(using!q{ d2 = new DisposableInt(2) });
static assert(is(typeof(di) == DisposableInt));
static assert(is(typeof(d2) == DisposableInt));
```

## Provided classes/methods

- `interface Disposable`
    - A `Disposable` interface that can be disposed by calling `dispose` method
    - `nothrow void dispose()`
        - Disposes unmanaged objects(OpenGL Objects, Win32 Objects...) in the object.

- `string using(string)() {...}`
    - The `using` statement emulation.
    - Passes a variable declaration statement as string(using `q{...}` is preferred) to declare a variable and to insert a code such as `scope(exit) {varname}.dispose();`
    - If you want a type which is inferred, you can omit `auto`.
