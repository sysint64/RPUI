module time;

struct Interval {
    float timeout;
    void delegate() onTimeout;

    /// It true, after time is out timer will stops working else repeat interval.
    bool haltOnTimout;

    private float time;
    private bool halt = true;

    void onProgress(in float deltaTime) {
        if (halt)
            return;

        time += deltaTime;

        if (time >= timeout) {
            onTimeout();

            if (haltOnTimout) {
                halt = true;
            } else {
                time = 0;
            }
        }
    }

    void start() {
        halt = false;
        time = 0;
    }

    void stop() {
        halt = true;
    }

    bool isStarted() {
        return !halt;
    }
}

Interval createTimeout(in float timeout, void delegate() onTimeout) {
    return Interval(timeout, onTimeout, true);
}

Interval createInterval(in float timeout, void delegate() onTimeout) {
    return Interval(timeout, onTimeout, false);
}
