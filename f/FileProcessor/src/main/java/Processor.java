package main.java;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class Processor implements Runnable
{
    private static final ExecutorService service = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
    private static final ScheduledExecutorService executor = Executors.newScheduledThreadPool(2);
    private static final OMSMessageDao dao = new OMSMessageDao();
    private final DirtyCache cache = new DirtyCache();

    @Override
    public void run()
    {
        executor.scheduleAtFixedRate(dao, 0, 5, TimeUnit.SECONDS);
        executor.scheduleAtFixedRate(cache, 0, 5, TimeUnit.SECONDS);
        service.submit(new FileProcessor(FileImport.WORKING, dao));
        service.submit(new FileProcessor(FileImport.PATH, dao));
    }

    public static void main(String[] args)
    {
        try
        {
            ExecutorService service = Executors.newSingleThreadExecutor();
            service.submit(new Processor());
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }
}
