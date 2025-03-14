package com.function;

import java.util.concurrent.atomic.AtomicInteger;

public final class DependencyFactory {

    private static AtomicInteger atomicInteger = new AtomicInteger(0);

    /**
     * On first call from JVM (or after GC), instantiates EnrichFunctionProperties and returns them.
     * Subsequent calls return existing instance.
     *
     * @return the Enrich Function Properties
     */
    public static synchronized String enrichFunctionProperties() {
        atomicInteger.incrementAndGet();
        return String.format("Enrich Function Properties invoked. Atomic counter: %d", atomicInteger.get());
    }
}