package main.java;

import com.salerio.idm.system.oms.jaxb.imp.SecurityAllocation;
import com.salerio.idm.system.oms.jaxb.imp.SecurityExecution;
import com.salerio.idm.system.oms.jaxb.imp.Trade;
import java.io.File;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.locks.ReentrantLock;

public class OMSMessageDao implements Runnable
{
    private Connection connection;
    private Queue<File> trades = new ConcurrentLinkedQueue<File>();
    private final ReentrantLock lock = new ReentrantLock();
    private final String blocksql = "INSERT INTO mh_oms_message(omsref, parentref, type, qty, status, originalmessage, crdate, fileimportstart) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    private final String allocsql = "INSERT INTO mh_oms_message(omsref, parentref, type, qty, status, originalmessage, crdate, fileimportstart) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

    private PreparedStatement blockStatement;
    private PreparedStatement allocStatement;

    private final Enrichment enrichment = new Enrichment();

    private final JAXBProcessor processor = new JAXBProcessor();

    public OMSMessageDao()
    {
        try
        {
            connection = DriverManager.getConnection("jdbc:sqlserver://localhost:1433;databaseName=oms", "sa", "password");

            System.out.println("connected");
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    @Override
    public void run()
    {
        lock.lock();
        System.out.println("found " + trades.size() + " trades to process");
        try
        {
            blockStatement = connection.prepareStatement(blocksql);
            allocStatement = connection.prepareStatement(allocsql);

            for (File file : trades)
            {
                Trade trade = processor.getTradeData(file);

                if (trade != null)
                {
                    // we know the process is fine and we got the trade object - we can move it to
                    // processed now
                    // and we dont care about the concept of a file anymore
                    moveFileToProcessed(file.toPath());
                    processBlocks(trade);
                    processAllocations(trade);

                    blockStatement.executeBatch();
                    allocStatement.executeBatch();

                    // if we get to here then so far everything has been successful. We have
                    // managed to add blocks and allocs to the table and we are now in a state
                    // that we can do all of the processing and then move them to a processed state.

                    // in order to do the processing lets create a wrapper class that holds the
                    // blocks
                    // and allocations for a particular file and lets store the original file there
                    // too.
                    // This should mean we have everything we need in order to handle failed items.
                    BlockAndAndAllocWrapper wrapper = new BlockAndAndAllocWrapper(file, trade.getSecurityExecution(),
                            trade.getSecurityAllocation());
                    enrichment.addFile(wrapper);
                    trades.remove(file);
                }
            }

        }
        catch (Exception e)
        {
            e.printStackTrace();
        }

        trades.clear();
        lock.unlock();

    }

    private void moveFileToProcessed(Path filename)
    {
        try
        {
            Path movefrom = FileSystems.getDefault().getPath(FileImport.WORKING + File.separator + filename.getFileName());
            Path target = FileSystems.getDefault().getPath(FileImport.PROCESSED + File.separator + filename.getFileName());
            Files.move(movefrom, target, StandardCopyOption.REPLACE_EXISTING);
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    private void processAllocations(Trade trade)
    {
        try
        {
            if (trade != null)
            {
                for (SecurityAllocation allocation : trade.getSecurityAllocation())
                {
                    allocStatement.setString(1, allocation.getAllocationIdentifier());
                    allocStatement.setString(2, allocation.getExecutionIdentifier());
                    allocStatement.setString(3, "NEWM");
                    allocStatement.setBigDecimal(4, allocation.getAllocationDetails().getQuantity().getValue());
                    allocStatement.setString(5, "STATUS");
                    allocStatement.setString(6, processor.allocMarshall(allocation));
                    allocStatement.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
                    allocStatement.setTimestamp(8, new Timestamp(System.currentTimeMillis()));
                    allocStatement.addBatch();
                }
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    private void processBlocks(Trade trade)
    {
        try
        {
            if (trade != null)
            {
                for (SecurityExecution execution : trade.getSecurityExecution())
                {
                    blockStatement.setString(1, execution.getExecutionIdentifier());
                    blockStatement.setString(2, null);
                    blockStatement.setString(3, "NEWM");
                    blockStatement.setBigDecimal(4, execution.getExecutionDetails().getQuantity().getValue());
                    blockStatement.setString(5, "STATUS");
                    blockStatement.setString(6, processor.execMarshall(execution));
                    blockStatement.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
                    blockStatement.setTimestamp(8, new Timestamp(System.currentTimeMillis()));
                    blockStatement.addBatch();
                }
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    public void processFile(File file)
    {
        lock.lock();
        trades.add(file);
        lock.unlock();
    }
}
