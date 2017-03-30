package main.java;

import com.salerio.idm.system.oms.jaxb.imp.SecurityAllocation;
import com.salerio.idm.system.oms.jaxb.imp.SecurityExecution;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.locks.ReentrantLock;
import main.java.DirtyCache.CacheType;

public class Enrichment implements Runnable
{
    private Queue<BlockAndAndAllocWrapper> trades = new ConcurrentLinkedQueue<BlockAndAndAllocWrapper>();
    private final ReentrantLock lock = new ReentrantLock();

    @Override
    public void run()
    {
        processQueue();
    }

    private void processQueue()
    {
        lock.lock();
        try
        {
            for (BlockAndAndAllocWrapper wrapper : trades)
            {

                for (SecurityExecution block : wrapper.getSecurityExecutions())
                {
                    DirtyCache.checkCache(block, CacheType.BLOCK);
                }

                for (SecurityAllocation alloc : wrapper.getSecurityAllocations())
                {
                    DirtyCache.checkCache(alloc, CacheType.ALLOCATION);
                }
                trades.remove(wrapper);
            }
        }
        finally
        {
            lock.unlock();
        }
    }

    public void addFile(BlockAndAndAllocWrapper wrapper)
    {
        lock.lock();
        try
        {
            trades.add(wrapper);
        }
        finally
        {
            lock.unlock();
        }
    }
}
