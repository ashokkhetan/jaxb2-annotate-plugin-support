package main.java;

import com.salerio.idm.system.oms.jaxb.imp.SecurityAllocation;
import com.salerio.idm.system.oms.jaxb.imp.SecurityExecution;
import com.salerio.idm.system.oms.jaxb.imp.Trade;
import java.io.File;
import java.io.StringWriter;
import javax.xml.XMLConstants;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;
import javax.xml.namespace.QName;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

public class JAXBProcessor
{
    private JAXBContext jaxbContext;
    private Unmarshaller jaxbUnmarshaller;
    private SchemaFactory schemaFactory;
    private Schema compiledSchema;

    private JAXBContext alloccontext;
    private Marshaller allocMarshaller;
    private QName allocqName = new QName("com.salerio.idm.system.oms.jaxb.imp.SecurityAllocation", "SecurityAllocation");

    private JAXBContext blockcontext;
    private Marshaller blockMarshaller;
    private QName blockqName = new QName("com.salerio.idm.system.oms.jaxb.imp.SecurityAllocation", "SecurityExecution");

    public JAXBProcessor()
    {
        try
        {
            jaxbContext = JAXBContext.newInstance(Trade.class);
            jaxbUnmarshaller = jaxbContext.createUnmarshaller();
            schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
            compiledSchema = schemaFactory.newSchema(getClass().getClassLoader().getResource("import.xsd"));
            jaxbUnmarshaller.setSchema(compiledSchema);
            alloccontext = JAXBContext.newInstance(SecurityAllocation.class);
            allocMarshaller = alloccontext.createMarshaller();

            blockcontext = JAXBContext.newInstance(SecurityExecution.class);
            blockMarshaller = blockcontext.createMarshaller();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    public String allocMarshall(SecurityAllocation allocation)
    {
        try
        {
            StringWriter writer = new StringWriter();
            allocMarshaller.marshal(getJaxBAllocationElement(allocation), writer);
            return writer.toString();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        return null;
    }

    public String execMarshall(SecurityExecution execution)
    {
        try
        {
            StringWriter writer = new StringWriter();
            blockMarshaller.marshal(getJaxBAExecutionElement(execution), writer);
            return writer.toString();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        return null;
    }

    public Trade getTradeData(File file)
    {
        try
        {
            JAXBElement<Trade> trade = jaxbUnmarshaller.unmarshal(new StreamSource(file), Trade.class);
            return trade.getValue();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        return null;
    }

    private JAXBElement<SecurityAllocation> getJaxBAllocationElement(SecurityAllocation allocation)
    {
        return new JAXBElement<SecurityAllocation>(allocqName, SecurityAllocation.class, allocation);
    }

    private JAXBElement<SecurityExecution> getJaxBAExecutionElement(SecurityExecution execution)
    {
        return new JAXBElement<SecurityExecution>(blockqName, SecurityExecution.class, execution);
    }

}
