package main.java;

import com.salerio.idm.system.oms.jaxb.imp.SecurityAllocation;
import com.salerio.idm.system.oms.jaxb.imp.SecurityExecution;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.locks.ReentrantLock;

public class DirtyCache implements Runnable
{
    public enum CacheType
    {
        BLOCK, ALLOCATION;
    };

    private Connection connection;
    private PreparedStatement ps;

    private static final Set<String> BROKER_CACHE = Collections.synchronizedSet(new HashSet<String>());
    private static final Set<String> INSTRUMENT_CACHE = Collections.synchronizedSet(new HashSet<String>());
    private static final Set<String> CURRENCY_CACHE = Collections.synchronizedSet(new HashSet<String>());
    private static final Set<String> MARKET_CACHE = Collections.synchronizedSet(new HashSet<String>());
    private static final Set<String> COUNTRY_CACHE = Collections.synchronizedSet(new HashSet<String>());
    private static final Set<String> OMS_CACHE = Collections.synchronizedSet(new HashSet<String>());
    private static final Set<String> PORTFOLIO_CACHE = Collections.synchronizedSet(new HashSet<String>());

    private static final ReentrantLock LOCK = new ReentrantLock();

    @Override
    public void run()
    {
        updateCache();
    }

    public static boolean checkCache(Object obj, CacheType type)
    {
        try
        {
            LOCK.lock();
            switch (type)
            {
                case BLOCK:
                    return checkBlockCache((SecurityExecution)obj);
                case ALLOCATION:
                    return checkAllocCache((SecurityAllocation)obj);
            }
        }
        finally
        {
            LOCK.unlock();
        }
        return false;
    }

    private static boolean checkAllocCache(SecurityAllocation allocation)
    {
        return BROKER_CACHE.contains(allocation.getExecutionDetails().getExecutingBroker().getReference())
                && INSTRUMENT_CACHE.contains(allocation.getExecutionDetails().getSecurity().getType())
                && CURRENCY_CACHE.contains(allocation.getAllocationDetails().getGrossAmount().getCurrency())
                && MARKET_CACHE.contains(allocation.getExecutionDetails().getMarket())
                && COUNTRY_CACHE.contains(allocation.getExecutionDetails().getMarket())
                && OMS_CACHE.contains(allocation.getOrderManagementSystem().getReference())
                && CURRENCY_CACHE.contains(allocation.getAllocationDetails().getSettlementAmount().getCurrency())
                && PORTFOLIO_CACHE.contains(allocation.getAllocationDetails().getPortfolio().getReference());
    }

    private static boolean checkBlockCache(SecurityExecution block)
    {
        return BROKER_CACHE.contains(block.getExecutionDetails().getExecutingBroker().getReference())
                && INSTRUMENT_CACHE.contains(block.getExecutionDetails().getSecurity().getType())
                && CURRENCY_CACHE.contains(block.getExecutionDetails().getGrossAmount().getCurrency())
                && MARKET_CACHE.contains(block.getExecutionDetails().getMarket())
                && COUNTRY_CACHE.contains(block.getExecutionDetails().getMarket())
                && OMS_CACHE.contains(block.getOrderManagementSystem().getReference());
    }

    private void updateCache()
    {
        try
        {
            LOCK.lock();
            connection = DriverManager.getConnection("jdbc:sqlserver://STPSQLSERVER1\\SQLLATIN_2K8:4441;databaseName=RBC", "sa",
                    "Password10");

            ps = connection.prepareStatement("SELECT brkref FROM sbrk");
            ResultSet rs = ps.executeQuery();
            while (rs.next())
            {
                BROKER_CACHE.add(rs.getString("brkref").trim());
                System.out.println(rs.getString("brkref").trim() + " cached");
            }

            rs.close();
            ps.close();

            ps = connection.prepareStatement("SELECT insttyp FROM sinsttyp");
            rs = ps.executeQuery();
            while (rs.next())
            {
                INSTRUMENT_CACHE.add(rs.getString("insttyp").trim());
                System.out.println(rs.getString("insttyp").trim() + " cached");
            }

            rs.close();
            ps.close();

            ps = connection.prepareStatement("SELECT curref FROM scurr");
            rs = ps.executeQuery();
            while (rs.next())
            {
                CURRENCY_CACHE.add(rs.getString("curref").trim());
                System.out.println(rs.getString("curref").trim() + " cached");
            }

            rs.close();
            ps.close();

            ps = connection.prepareStatement("SELECT curref FROM scurr");
            rs = ps.executeQuery();
            while (rs.next())
            {
                CURRENCY_CACHE.add(rs.getString("curref").trim());
                System.out.println(rs.getString("curref").trim() + " cached");
            }

            rs.close();
            ps.close();

            ps = connection.prepareStatement("SELECT mktref FROM smkt");
            rs = ps.executeQuery();
            while (rs.next())
            {
                MARKET_CACHE.add(rs.getString("mktref").trim());
                System.out.println(rs.getString("mktref").trim() + " cached");
            }

            rs.close();
            ps.close();

            ps = connection.prepareStatement("SELECT ctryref FROM sctry");
            rs = ps.executeQuery();
            while (rs.next())
            {
                COUNTRY_CACHE.add(rs.getString("ctryref").trim());
                System.out.println(rs.getString("ctryref").trim() + " cached");
            }

            rs.close();
            ps.close();

            ps = connection.prepareStatement("SELECT omsref FROM soms");
            rs = ps.executeQuery();
            while (rs.next())
            {
                OMS_CACHE.add(rs.getString("omsref").trim());
                System.out.println(rs.getString("omsref").trim() + " cached");
            }

            rs.close();
            ps.close();

            ps = connection.prepareStatement("SELECT portref FROM sportf");
            rs = ps.executeQuery();
            while (rs.next())
            {
                PORTFOLIO_CACHE.add(rs.getString("portref").trim());
                System.out.println(rs.getString("portref").trim() + " cached");
            }

            rs.close();
            ps.close();
            connection.close();
        }
        catch (SQLException e)
        {
            e.printStackTrace();
        }
        finally
        {
            LOCK.unlock();
        }
    }
}
