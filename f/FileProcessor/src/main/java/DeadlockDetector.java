package main.java;

import java.lang.management.ManagementFactory;
import java.lang.management.ThreadInfo;
import java.lang.management.ThreadMXBean;

public class DeadlockDetector implements Runnable
{

    @Override
    public void run()
    {
        System.out.println("DETECTING DEADLOCKS ............... ");
        ThreadMXBean bean = ManagementFactory.getThreadMXBean();
        long[] threadIds = bean.findDeadlockedThreads(); // Returns null if no threads are
                                                         // deadlocked.

        if (threadIds != null)
        {
            ThreadInfo[] infos = bean.getThreadInfo(threadIds);

            for (ThreadInfo info : infos)
            {
                StackTraceElement[] stack = info.getStackTrace();
                for (StackTraceElement t : stack)
                {
                    System.out.println(t.getMethodName() + " " + t.getLineNumber());
                }
            }
        }
    }

}
