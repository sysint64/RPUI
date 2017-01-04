module patterns.singleton;


mixin template Singleton(T) {
    static T getInstance() {
        if (instantiated)
            return instance;

        synchronized(T.classinfo) {
            if (!instance)
                instance = new T();

            instantiated = true;
        }

        return instance;
    }

    private this() {}
    private static bool instantiated;
    private __gshared T instance;
}
