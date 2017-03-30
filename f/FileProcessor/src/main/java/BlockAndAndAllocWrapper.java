package main.java;

import com.salerio.idm.system.oms.jaxb.imp.SecurityAllocation;
import com.salerio.idm.system.oms.jaxb.imp.SecurityExecution;
import java.io.File;
import java.util.List;

public class BlockAndAndAllocWrapper
{
    private final File file;
    private final List<SecurityExecution> securityExecutions;
    private final List<SecurityAllocation> securityAllocations;

    public BlockAndAndAllocWrapper(File file, List<SecurityExecution> securityExecutions, List<SecurityAllocation> securityAllocations)
    {
        this.file = file;
        this.securityExecutions = securityExecutions;
        this.securityAllocations = securityAllocations;
    }

    public File getFile()
    {
        return file;
    }

    public List<SecurityExecution> getSecurityExecutions()
    {
        return securityExecutions;
    }

    public List<SecurityAllocation> getSecurityAllocations()
    {
        return securityAllocations;
    }
}
