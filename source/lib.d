/// Disposable

/// Indicates that the object(or the inner object in it) can be disposable manually+immediately
interface Disposable
{
    /// Disposes unmanaged objects in the object
    public nothrow void dispose();
}

/// Scope guard simulating the `using` statement in C#
struct UsingGuard(T: Disposable)
{
    /// Inner reference to an object
    public T ptr;
    alias ptr this;

    /// Copy Constructor: Prohibited
    public this(this) @disable;
    /// Move Constructor: Prohibited
    public this(U: Disposable)(UsingGuard!U) @disable;
    /// This is an unsafe operation because the application cannot access to the source object
    private this(T src) { this.ptr = src; }

    ~this()
    {
        /// Dispose inner pointer
        this.ptr.dispose();
    }
}

/// extended syntax: using!q{ {auto/type} {varname} = {expr}; }
pure using(string Q)()
{
    import std.algorithm : map, strip;
    import std.array : split;
    import std.ascii : isWhite;
    import std.string : join;
    auto ve = Q.split("=").map!(x => x.strip!isWhite);
    auto tv = ve[0].split!isWhite.map!(x => x.strip!isWhite);
    return (tv.length <= 1 ? "auto " ~ Q : Q) ~ "; scope(exit) " ~ tv[$ - 1] ~ ".dispose();";
}

// Using Guard
unittest
{
    import std.stdio : writeln;

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
}
// Nested Disposables
unittest
{
    class DisposableIntInner : Disposable
    {
        private int v;
        private bool disposed;

        this(int t) { this.v = t; }
        ~this() { this.dispose(false); }

        override nothrow void dispose() { this.dispose(true); }
        nothrow void dispose(bool disposing)
        {
            assert(disposing != this.disposed);
            this.disposed = true;
        }
    }
    class DisposableIntOuter : Disposable
    {
        private int v;
        private DisposableIntInner inner;
        private bool disposed;

        this(int t) { this.v = t; this.inner = new DisposableIntInner(t * 2); }
        ~this() { this.dispose(false); }

        override nothrow void dispose() { this.dispose(true); }
        nothrow void dispose(bool disposing)
        {
            assert(this.disposed != disposing);
            if(disposing) this.inner.dispose();
            this.disposed = true;
        }
    }

    mixin(using!q{ od = new DisposableIntOuter(4) });
}
