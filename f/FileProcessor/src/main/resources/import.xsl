<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml" indent="yes"/>
    <!--Unless we have explicitly mapped a value we may just ignore it.-->
    <xsl:template match="*"/>

    <!--xsl:template match="/">
        <xsl:apply-templates select="TradeData"/>
    </xsl:template-->

    <xsl:template match="Trade">
        <SALERIODatabase>
            <xsl:apply-templates select="SecurityAllocation"/>
            <xsl:apply-templates select="SecurityExecution"/>
        </SALERIODatabase>
    </xsl:template>
    
    <xsl:template match="SecurityExecution">
        <xsl:variable name="table">
            <xsl:choose>
                <xsl:when test="Function ='New'">tlocblk_imp</xsl:when>
                <xsl:when test="Function ='Cancel'">tlocblk_imp</xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        
        <SALERIODatabase>

        <Record>
            <xsl:attribute name="TableName">
                <xsl:value-of select="$table"/>
            </xsl:attribute>
            <xsl:attribute name="IdFieldName">sysid</xsl:attribute>

            <Field ColumnName="msgtextid" IsQuoted="false">
                <xsl:value-of select="/ImportMessage/@ArchiveImportId"/>
            </Field>
            <Field ColumnName="msgtextref" IsQuoted="true">
                <xsl:value-of select="/ImportMessage/@ArchiveImportRef"/>
            </Field>

            <Field ColumnName="cancel" IsQuoted="true">
                <xsl:choose>
                    <xsl:when test="Function = 'New'">N</xsl:when>
                    <xsl:when test="Function = 'Cancel'">Y</xsl:when>
                </xsl:choose>
            </Field>

            <xsl:call-template name="source">
                <xsl:with-param name="name">source</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="source">
                <xsl:with-param name="name">locsource</xsl:with-param>
            </xsl:call-template>
            <!--<Field ColumnName="sourceomsref" IsQuoted="true">-->
                <!--<xsl:value-of select="OrderManagementSystem/TradeIdentifier"/>-->
            <!--</Field>-->
            <Field ColumnName="omsref" IsQuoted="true">
                <xsl:choose>
                    <xsl:when test="boolean(ExecutionIdentifier)">
                        <xsl:value-of select="ExecutionIdentifier"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="OrderManagementSystem/TradeIdentifier"/>
                    </xsl:otherwise>
                </xsl:choose>
            </Field>
            <Field ColumnName="parentref" IsQuoted="true">
                <xsl:choose>
                    <xsl:when test="boolean(ExecutionIdentifier)">
                        <xsl:value-of select="ExecutionIdentifier"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="OrderManagementSystem/TradeIdentifier"/>
                    </xsl:otherwise>
                </xsl:choose>
            </Field>

            <!-- Execution Fields -->

            <Field ColumnName="brkref" IsQuoted="true">
                <xsl:value-of select="ExecutionDetails/ExecutingBroker/Reference"/>
            </Field>
            <Field ColumnName="sourcebrkref" IsQuoted="true">
                <xsl:value-of select="ExecutionDetails/ExecutingBroker/Reference"/>
            </Field>
            <xsl:variable name="trntyp">
                <xsl:value-of select="ExecutionDetails/BuySell"/>
            </xsl:variable>
            <Field ColumnName="trntyp" IsQuoted="true">
                <xsl:choose>
                    <xsl:when test="$trntyp = 'Buy'">B</xsl:when>
                    <xsl:otherwise>S</xsl:otherwise>
                </xsl:choose>
            </Field>
            <xsl:variable name="longShort">
                <xsl:value-of select="ExecutionDetails/LongShort"/>
            </xsl:variable>
            <Field ColumnName="shortlong" IsQuoted="true">
                <xsl:choose>
                    <xsl:when test="$longShort = 'Short'">S</xsl:when>
                    <xsl:otherwise>L</xsl:otherwise>
                </xsl:choose>
            </Field>
			<xsl:if test="boolean(ExecutionDetails/ConfirmationVenue)">
                <Field ColumnName="confvenue" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/ConfirmationVenue"/>
                </Field>
            </xsl:if>	
			<xsl:if test="boolean(ExecutionDetails/Repurchase/RepurchaseType)">
                <Field ColumnName="repotradtype" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Repurchase/RepurchaseType"/>
                </Field>
            </xsl:if>		
			<xsl:if test="boolean(ExecutionDetails/Repurchase/DeliveryMethod)">
                <Field ColumnName="repodelvmeth" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Repurchase/DeliveryMethod"/>
                </Field>
            </xsl:if>
			<xsl:if test="boolean(ExecutionDetails/Repurchase/Leg)">
                <Field ColumnName="repolegid" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Repurchase/Leg"/>
                </Field>
            </xsl:if>
			<xsl:if test="boolean(ExecutionDetails/Repurchase/RateType)">
                <Field ColumnName="reporatetyp" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Repurchase/RateType"/>
                </Field>
            </xsl:if>	
			<xsl:if test="boolean(ExecutionDetails/Repurchase/ConfirmPurpose)">
                <Field ColumnName="repoconfpurp" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Repurchase/ConfirmPurpose"/>
                </Field>
            </xsl:if>				
            <Field ColumnName="insttyp" IsQuoted="true">
                <xsl:value-of select="ExecutionDetails/Security/Type"/>
            </Field>
            <xsl:if test="boolean(ExecutionDetails/Security/Description)">
                <Field ColumnName="secdesc" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Security/Description"/>
                </Field>
            </xsl:if>
            <xsl:call-template name="securityReference">
                <xsl:with-param name="name">secisin</xsl:with-param>
                <xsl:with-param name="type">ISIN</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="securityReference">
                <xsl:with-param name="name">seccusip</xsl:with-param>
                <xsl:with-param name="type">CUSIP</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="securityReference">
                <xsl:with-param name="name">secsedol</xsl:with-param>
                <xsl:with-param name="type">SEDOL</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="securityReference">
                <xsl:with-param name="name">secticker</xsl:with-param>
                <xsl:with-param name="type">Ticker</xsl:with-param>
            </xsl:call-template>

            <xsl:choose>
                <xsl:when test="ExecutionDetails/Security/References/Reference[@Type='CUSIP']">
                    <xsl:call-template name="genericSecurityReference">
                        <xsl:with-param name="value">
                            <xsl:value-of select="ExecutionDetails/Security/References/Reference[@Type='CUSIP']"/>
                        </xsl:with-param>
                        <xsl:with-param name="type">CUS</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="ExecutionDetails/Security/References/Reference[@Type='SEDOL']">
                    <xsl:call-template name="genericSecurityReference">
                        <xsl:with-param name="value">
                            <xsl:value-of select="ExecutionDetails/Security/References/Reference[@Type='SEDOL']"/>
                        </xsl:with-param>
                        <xsl:with-param name="type">SED</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="ExecutionDetails/Security/References/Reference[@Type='ISIN']">
                    <xsl:call-template name="genericSecurityReference">
                        <xsl:with-param name="value">
                            <xsl:value-of select="ExecutionDetails/Security/References/Reference[@Type='ISIN']"/>
                        </xsl:with-param>
                        <xsl:with-param name="type">ISIN</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>

            <xsl:if test="boolean(ExecutionDetails/Security/IssueDate)">
                <xsl:call-template name="chardateField">
                    <xsl:with-param name="name">issuedate</xsl:with-param>
                    <xsl:with-param name="value" select="ExecutionDetails/Security/IssueDate"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:call-template name="yesnoField">
                <xsl:with-param name="name">whenissued</xsl:with-param>
                <xsl:with-param name="value" select="ExecutionDetails/Security/WhenIssued"/>
            </xsl:call-template>
            <xsl:if test="boolean(ExecutionDetails/Security/MaturityDate)">
                <xsl:call-template name="chardateField">
                    <xsl:with-param name="name">matdate</xsl:with-param>
                    <xsl:with-param name="value" select="ExecutionDetails/Security/MaturityDate"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Security/CouponRate)">
                <Field ColumnName="intrate" IsQuoted="false">
                    <xsl:value-of select="ExecutionDetails/Security/CouponRate"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Security/Yield)">
                <Field ColumnName="yld" IsQuoted="false">
                    <xsl:value-of select="ExecutionDetails/Security/Yield"/>
                </Field>
            </xsl:if>
            <xsl:call-template name="yesnoField">
                <xsl:with-param name="name">final_couperate</xsl:with-param>
                <xsl:with-param name="value" select="ExecutionDetails/Security/FinalCoupon"/>
            </xsl:call-template>			
            <xsl:if test="boolean(ExecutionDetails/Security/CurrentFactor)">
                <Field ColumnName="factor" IsQuoted="false">
                    <xsl:value-of select="ExecutionDetails/Security/CurrentFactor"/>
                </Field>
            </xsl:if>
			<xsl:call-template name="yesnoField">
                <xsl:with-param name="name">final_factor</xsl:with-param>
                <xsl:with-param name="value" select="ExecutionDetails/Security/FinalFactor"/>
            </xsl:call-template>
			<xsl:if test="boolean(ExecutionDetails/Security/PoolName)">
                <Field ColumnName="poolname" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Security/PoolName"/>
                </Field>
            </xsl:if>
			<xsl:if test="boolean(ExecutionDetails/Security/DiscountRate)">
                <Field ColumnName="discountrate" IsQuoted="false">
                    <xsl:value-of select="ExecutionDetails/Security/DiscountRate"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Security/Stipulations/MaxNumberOfPools)">
                <Field ColumnName="pools_maxnum" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Security/Stipulations/MaxNumberOfPools"/>
                </Field>
            </xsl:if>
            <xsl:call-template name="yesnoField">
                <xsl:with-param name="name">pool_onepiece</xsl:with-param>
                <xsl:with-param name="value" select="ExecutionDetails/Security/Stipulations/OnePoolPerPiece"/>
            </xsl:call-template>
			<xsl:call-template name="yesnoField">
                <xsl:with-param name="name">pools_permillionflag</xsl:with-param>
                <xsl:with-param name="value" select="ExecutionDetails/Security/Stipulations/OnePoolPerMillion"/>
            </xsl:call-template>
			<xsl:if test="boolean(ExecutionDetails/Security/Stipulations/Other)">
                <Field ColumnName="stipulationsother" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Security/Stipulations/Other"/>
                </Field>
            </xsl:if>			
            <xsl:if test="boolean(ExecutionDetails/Security/BargainCondition)">
                <xsl:variable name="bargainCondition">
                    <xsl:value-of select="ExecutionDetails/Security/BargainCondition"/>
                </xsl:variable>
                <Field ColumnName="bargcond" IsQuoted="true">
                    <xsl:choose>
                        <xsl:when test="$bargainCondition = 'ExDividend'">XD</xsl:when>
                        <xsl:otherwise>CD</xsl:otherwise>
                    </xsl:choose>
                </Field>
            </xsl:if>
			<xsl:if test="boolean(ExecutionDetails/Derivative/ExchangeTraded/Exchange)">
                <Field ColumnName="optexchangref" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Derivative/ExchangeTraded/Exchange"/>
                </Field>
            </xsl:if>
			<xsl:if test="boolean(ExecutionDetails/Derivative/ExchangeTraded/OptionType)">
                <Field ColumnName="opttype" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Derivative/ExchangeTraded/OptionType"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Derivative/ExchangeTraded/ExpirationDate)">
				<xsl:call-template name="chardateField">
					<xsl:with-param name="name">optexpiredate</xsl:with-param>
					<xsl:with-param name="value" select="ExecutionDetails/Derivative/ExchangeTraded/ExpirationDate"/>
				</xsl:call-template>	
			</xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Derivative/ExchangeTraded/DeliveryType)">
                <Field ColumnName="optdelvtyp" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Derivative/ExchangeTraded/DeliveryType"/>
                </Field>
            </xsl:if>
			<xsl:if test="boolean(ExecutionDetails/Derivative/ExchangeTraded/PremiumAmount)">
                <Field ColumnName="optpremamt" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Derivative/ExchangeTraded/PremiumAmount"/>
                </Field>
            </xsl:if>
			<xsl:if test="boolean(ExecutionDetails/Derivative/ExchangeTraded/StrikePrice)">
                <Field ColumnName="optstrikeprc" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Derivative/ExchangeTraded/StrikePrice"/>
                </Field>
            </xsl:if>			
            <xsl:if test="boolean(ExecutionDetails/Price/Type)">
                <xsl:variable name="cleanDirty">
                    <xsl:value-of select="ExecutionDetails/Price/Type"/>
                </xsl:variable>
                <Field ColumnName="cleandirty" IsQuoted="true">
                    <xsl:choose>
                        <xsl:when test="$cleanDirty = 'Clean'">C</xsl:when>
                        <xsl:otherwise>D</xsl:otherwise>
                    </xsl:choose>
                </Field>
            </xsl:if>					
            <Field ColumnName="prc" IsQuoted="false">
                <xsl:value-of select="ExecutionDetails/Price/Amount"/>
            </Field>
			<Field ColumnName="prcfact" IsQuoted="false">
                <xsl:value-of select="1"/>
            </Field>
            <xsl:call-template name="chardateField">
                <xsl:with-param name="name">traddate</xsl:with-param>
                <xsl:with-param name="value" select="ExecutionDetails/TradeDate"/>
            </xsl:call-template>
            <xsl:if test="boolean(ExecutionDetails/TradeTime)">
                <Field ColumnName="tradtime" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/TradeTime"/>
                </Field>
            </xsl:if>
            <xsl:call-template name="chardateField">
                <xsl:with-param name="name">setdate</xsl:with-param>
                <xsl:with-param name="value" select="ExecutionDetails/SettlementDate"/>
            </xsl:call-template>
            <Field ColumnName="mktref" IsQuoted="true">
                <xsl:value-of select="ExecutionDetails/Market"/>
            </Field>
            <Field ColumnName="ctryref" IsQuoted="true">
                <xsl:value-of select="ExecutionDetails/Market"/>
            </Field>
            <xsl:call-template name="yesnoField">
                <xsl:with-param name="name">freepay</xsl:with-param>
                <xsl:with-param name="value" select="ExecutionDetails/FreeOfPayment"/>
            </xsl:call-template>
            <xsl:if test="boolean(ExecutionDetails/NumberOfDaysAccrued)">
                <Field ColumnName="intdays" IsQuoted="false">
                    <xsl:value-of select="ExecutionDetails/NumberOfDaysAccrued"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Trader/Desk)">
                <Field ColumnName="tradedesk" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Trader/Desk"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Trader/Name)">
                <Field ColumnName="tradername" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Trader/Name"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Trader/Location)">
                <Field ColumnName="traderloc" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Trader/Location"/>
                </Field>
            </xsl:if>
            <Field ColumnName="qty" IsQuoted="false">
                <xsl:value-of select="ExecutionDetails/Quantity"/>
            </Field>

            <xsl:if test="boolean(ExecutionDetails/CurrentFaceValue)">
                <Field ColumnName="qtyamor" IsQuoted="false">
                    <xsl:value-of select="ExecutionDetails/CurrentFaceValue"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/UnitisedValue)">
                <Field ColumnName="qtyunit" IsQuoted="false">
                    <xsl:value-of select="ExecutionDetails/UnitisedValue"/>
                </Field>
            </xsl:if>

            <!--<xsl:call-template name="quantityType">-->

                <!--<xsl:with-param name="name">qtyflag</xsl:with-param>-->
                <!--<xsl:with-param name="value" select="ExecutionDetails/Quantity/@Type"/>-->
            <!--</xsl:call-template>-->

            <Field ColumnName="tradcurref" IsQuoted="true">
                <xsl:value-of select="ExecutionDetails/GrossAmount/Currency"/>
            </Field>
            <Field ColumnName="grosamt" IsQuoted="false">
                <xsl:value-of select="ExecutionDetails/GrossAmount/Amount"/>
            </Field>
            <xsl:call-template name="charge">
                <xsl:with-param name="name">loctax</xsl:with-param>
                <xsl:with-param name="type">LocalTax</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="charge">
                <xsl:with-param name="name">locfee</xsl:with-param>
                <xsl:with-param name="type">LocalFee</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="charge">
                <xsl:with-param name="name">other</xsl:with-param>
                <xsl:with-param name="type">Other</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="charge">
                <xsl:with-param name="name">isschrg</xsl:with-param>
                <xsl:with-param name="type">Issuer</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="brk_commission">
                <xsl:with-param name="name">brkcomm</xsl:with-param>
                <xsl:with-param name="type">Broker</xsl:with-param>
            </xsl:call-template>

            <xsl:if test="boolean(ExecutionDetails/InterestAmount/Amount)">
                <Field ColumnName="intamt" IsQuoted="false">
                    <xsl:value-of select="ExecutionDetails/InterestAmount/Amount"/>
                </Field>
            </xsl:if>
            <Field ColumnName="netamt" IsQuoted="false">
                <xsl:value-of select="ExecutionDetails/NetAmount/Amount"/>
            </Field>
            <Field ColumnName="setcurref" IsQuoted="true">
                <xsl:value-of select="ExecutionDetails/SettlementAmount/Currency"/>
            </Field>
            <Field ColumnName="setamt" IsQuoted="false">
                <xsl:value-of select="ExecutionDetails/SettlementAmount/Amount"/>
            </Field>

            <!-- Related -->

            <!--<xsl:call-template name="yesnoField">-->
                <!--<xsl:with-param name="name">rebook</xsl:with-param>-->
                <!--<xsl:with-param name="value" select="Related/Rebooked"/>-->
            <!--</xsl:call-template>-->
            <!--<xsl:if test="boolean(Related/RebookedIdentifier)">-->
                <!--<Field ColumnName="origomsref" IsQuoted="true">-->
                    <!--<xsl:value-of select="Related/RebookedIdentifier"/>-->
                <!--</Field>-->
            <!--</xsl:if>-->
			
            <xsl:call-template name="yesnoField">
                <xsl:with-param name="name">rebook</xsl:with-param>
                <xsl:with-param name="value" select="Related/Rebooked"/>
            </xsl:call-template>
            <xsl:if test="boolean(Related/RebookedIdentifier)">
                <Field ColumnName="origomsref" IsQuoted="true">
                    <xsl:value-of select="Related/RebookedIdentifier"/>
                </Field>
            </xsl:if>					

            <Field ColumnName="sysrev" IsQuoted="false">1</Field>
            <Field ColumnName="processing" IsQuoted="true">N</Field>
        </Record>
        
        </SALERIODatabase>
        
    </xsl:template>
    <xsl:template match="SecurityAllocation">
        <xsl:variable name="table">
            <xsl:choose>
                <xsl:when test="Function ='New'">tlocseta_imp</xsl:when>
                <xsl:when test="Function ='Cancel'">tlocseta_imp</xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <SALERIODatabase>

        <Record>
            <xsl:attribute name="TableName">
                <xsl:value-of select="$table"/>
            </xsl:attribute>
            <xsl:attribute name="IdFieldName">sysid</xsl:attribute>

            <Field ColumnName="msgtextid" IsQuoted="false">
                <xsl:value-of select="/ImportMessage/@ArchiveImportId"/>
            </Field>
            <Field ColumnName="msgtextref" IsQuoted="true">
                <xsl:value-of select="/ImportMessage/@ArchiveImportRef"/>
            </Field>

            <Field ColumnName="cancel" IsQuoted="true">
                <xsl:choose>
                    <xsl:when test="Function = 'New'">N</xsl:when>
                    <xsl:when test="Function = 'Cancel'">Y</xsl:when>
                </xsl:choose>
            </Field>

            <xsl:call-template name="source">
                <xsl:with-param name="name">source</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="source">
                <xsl:with-param name="name">locsource</xsl:with-param>
            </xsl:call-template>
            <Field ColumnName="sourceomsref" IsQuoted="true">
                <xsl:value-of select="OrderManagementSystem/TradeIdentifier"/>
            </Field>
            <Field ColumnName="omsref" IsQuoted="true">
                <xsl:choose>
                    <xsl:when test="boolean(AllocationIdentifier)">
                        <xsl:value-of select="AllocationIdentifier"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="OrderManagementSystem/TradeIdentifier"/>
                    </xsl:otherwise>
                </xsl:choose>
            </Field>

            <!-- Execution Fields -->
            <Field ColumnName="parentref" IsQuoted="true">
                <xsl:value-of select="ExecutionIdentifier"/>
            </Field>
            <Field ColumnName="brkref" IsQuoted="true">
                <xsl:value-of select="ExecutionDetails/ExecutingBroker/Reference"/>
            </Field>
            <Field ColumnName="sourcebrkref" IsQuoted="true">
                <xsl:value-of select="ExecutionDetails/ExecutingBroker/Reference"/>
            </Field>
            <xsl:variable name="trntyp">
                <xsl:value-of select="ExecutionDetails/BuySell"/>
            </xsl:variable>
            <Field ColumnName="trntyp" IsQuoted="true">
                <xsl:choose>
                    <xsl:when test="$trntyp = 'Buy'">B</xsl:when>
                    <xsl:otherwise>S</xsl:otherwise>
                </xsl:choose>
            </Field>
            <xsl:variable name="longShort">
                <xsl:value-of select="ExecutionDetails/LongShort"/>
            </xsl:variable>
            <Field ColumnName="shortlong" IsQuoted="true">
                <xsl:choose>
                    <xsl:when test="$longShort = 'Short'">S</xsl:when>
                    <xsl:otherwise>L</xsl:otherwise>
                </xsl:choose>
            </Field>
            <Field ColumnName="insttyp" IsQuoted="true">
                <xsl:value-of select="ExecutionDetails/Security/Type"/>
            </Field>
            <xsl:if test="boolean(ExecutionDetails/Security/Description)">
                <Field ColumnName="secdesc" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Security/Description"/>
                </Field>
            </xsl:if>
            <xsl:call-template name="securityReference">
                <xsl:with-param name="name">secisin</xsl:with-param>
                <xsl:with-param name="type">ISIN</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="securityReference">
                <xsl:with-param name="name">seccusip</xsl:with-param>
                <xsl:with-param name="type">CUSIP</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="securityReference">
                <xsl:with-param name="name">secsedol</xsl:with-param>
                <xsl:with-param name="type">SEDOL</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="securityReference">
                <xsl:with-param name="name">secticker</xsl:with-param>
                <xsl:with-param name="type">Ticker</xsl:with-param>
            </xsl:call-template>

            <xsl:choose>
                <xsl:when test="ExecutionDetails/Security/References/Reference[@Type='CUSIP']">
                    <xsl:call-template name="genericSecurityReference">
                        <xsl:with-param name="value">
                            <xsl:value-of select="ExecutionDetails/Security/References/Reference[@Type='CUSIP']"/>
                        </xsl:with-param>
                        <xsl:with-param name="type">CUS</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="ExecutionDetails/Security/References/Reference[@Type='SEDOL']">
                    <xsl:call-template name="genericSecurityReference">
                        <xsl:with-param name="value">
                            <xsl:value-of select="ExecutionDetails/Security/References/Reference[@Type='SEDOL']"/>
                        </xsl:with-param>
                        <xsl:with-param name="type">SED</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="ExecutionDetails/Security/References/Reference[@Type='ISIN']">
                    <xsl:call-template name="genericSecurityReference">
                        <xsl:with-param name="value">
                            <xsl:value-of select="ExecutionDetails/Security/References/Reference[@Type='ISIN']"/>
                        </xsl:with-param>
                        <xsl:with-param name="type">ISIN</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>

            <xsl:if test="boolean(ExecutionDetails/Security/IssueDate)">
                <xsl:call-template name="chardateField">
                    <xsl:with-param name="name">issuedate</xsl:with-param>
                    <xsl:with-param name="value" select="ExecutionDetails/Security/IssueDate"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Security/MaturityDate)">
                <xsl:call-template name="chardateField">
                    <xsl:with-param name="name">matdate</xsl:with-param>
                    <xsl:with-param name="value" select="ExecutionDetails/Security/MaturityDate"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Security/CouponRate)">
                <Field ColumnName="intrate" IsQuoted="false">
                    <xsl:value-of select="ExecutionDetails/Security/CouponRate"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Security/CurrentFactor)">
                <Field ColumnName="factor" IsQuoted="false">
                    <xsl:value-of select="ExecutionDetails/Security/CurrentFactor"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Security/BargainCondition)">
                <xsl:variable name="bargainCondition">
                    <xsl:value-of select="ExecutionDetails/Security/BargainCondition"/>
                </xsl:variable>
                <Field ColumnName="bargcond" IsQuoted="true">
                    <xsl:choose>
                        <xsl:when test="$bargainCondition = 'ExDividend'">XD</xsl:when>
                        <xsl:otherwise>CD</xsl:otherwise>
                    </xsl:choose>
                </Field>
            </xsl:if>
            <!-- Commented out as Invesco do not want the resulting 22F STCO tag.  Maybe required in the future [INV-90]
                        <xsl:if test="boolean(ExecutionDetails/Price/Type)">
                            <xsl:variable name="cleanDirty">
                                <xsl:value-of select="ExecutionDetails/Price/Type"/>
                            </xsl:variable>
                            <Field ColumnName="cleandirty" IsQuoted="true">
                                <xsl:choose>
                                    <xsl:when test="$cleanDirty = 'Clean'">C</xsl:when>
                                    <xsl:otherwise>D</xsl:otherwise>
                                </xsl:choose>
                            </Field>
                        </xsl:if>
            -->
            <xsl:if test="boolean(ExecutionDetails/Price/Type)">
                <xsl:variable name="priceType">
                    <xsl:value-of select="ExecutionDetails/Price/Type"/>
                </xsl:variable>
                <Field ColumnName="cleandirty" IsQuoted="true">
                    <xsl:choose>
                        <xsl:when test="$priceType = 'Clean'">C</xsl:when>
                        <xsl:otherwise>D</xsl:otherwise>
                    </xsl:choose>
                </Field>
            </xsl:if>
            <Field ColumnName="prc" IsQuoted="false">
                <xsl:value-of select="ExecutionDetails/Price/Amount"/>
            </Field>
            <xsl:call-template name="chardateField">
                <xsl:with-param name="name">traddate</xsl:with-param>
                <xsl:with-param name="value" select="ExecutionDetails/TradeDate"/>
            </xsl:call-template>
            <xsl:if test="boolean(ExecutionDetails/TradeTime)">
                <Field ColumnName="tradtime" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/TradeTime"/>
                </Field>
            </xsl:if>
            <xsl:call-template name="chardateField">
                <xsl:with-param name="name">setdate</xsl:with-param>
                <xsl:with-param name="value" select="ExecutionDetails/SettlementDate"/>
            </xsl:call-template>
            <Field ColumnName="mktref" IsQuoted="true">
                <xsl:value-of select="ExecutionDetails/Market"/>
            </Field>
            <Field ColumnName="ctryref" IsQuoted="true">
                <xsl:value-of select="ExecutionDetails/Market"/>
            </Field>
            <xsl:call-template name="yesnoField">
                <xsl:with-param name="name">freepay</xsl:with-param>
                <xsl:with-param name="value" select="ExecutionDetails/FreeOfPayment"/>
            </xsl:call-template>
            <xsl:if test="boolean(ExecutionDetails/NumberOfDaysAccrued)">
                <Field ColumnName="intdays" IsQuoted="false">
                    <xsl:value-of select="ExecutionDetails/NumberOfDaysAccrued"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Trader/Desk)">
                <Field ColumnName="tradedesk" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Trader/Desk"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Trader/Name)">
                <Field ColumnName="tradername" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Trader/Name"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(ExecutionDetails/Trader/Location)">
                <Field ColumnName="traderloc" IsQuoted="true">
                    <xsl:value-of select="ExecutionDetails/Trader/Location"/>
                </Field>
            </xsl:if>

            <!-- Allocation Fields -->

            <xsl:if test="boolean(AllocationDetails/StepOutBroker/Reference)">
                <Field ColumnName="stepoutbrkref" IsQuoted="true">
                    <xsl:value-of select="AllocationDetails/StepOutBroker/Reference"/>
                </Field>
            </xsl:if>
			<xsl:if test="boolean(AllocationDetails/StepOutBroker/Comment)">
                <Field ColumnName="stepoutcomment" IsQuoted="true">
                    <xsl:value-of select="AllocationDetails/StepOutBroker/Comment"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(AllocationDetails/BrokerOfCredit/Reference)">
                <Field ColumnName="brkcreditref" IsQuoted="true">
                    <xsl:value-of select="AllocationDetails/BrokerOfCredit/Reference"/>
                </Field>
            </xsl:if>			
            <xsl:if test="boolean(AllocationDetails/ClearingBroker/Reference)">
                <Field ColumnName="clrbrkref" IsQuoted="true">
                    <xsl:value-of select="AllocationDetails/ClearingBroker/Reference"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(AllocationDetails/Portfolio/Reference)">
                <Field ColumnName="portref" IsQuoted="true">
                    <xsl:value-of select="AllocationDetails/Portfolio/Reference"/>
                </Field>
                <Field ColumnName="sourceportref" IsQuoted="true">
                    <xsl:value-of select="AllocationDetails/Portfolio/Reference"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(AllocationDetails/Custodian/Reference)">
                <Field ColumnName="custref" IsQuoted="true">
                    <xsl:value-of select="AllocationDetails/Custodian/Reference"/>
                </Field>
            </xsl:if>
            <Field ColumnName="qty" IsQuoted="false">
                <xsl:value-of select="AllocationDetails/Quantity"/>
            </Field>
            <xsl:if test="boolean(AllocationDetails/CurrentFaceValue)">
                <Field ColumnName="qtyamor" IsQuoted="false">
                    <xsl:value-of select="AllocationDetails/CurrentFaceValue"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(AllocationDetails/UnitisedValue)">
                <Field ColumnName="qtyunit" IsQuoted="false">
                    <xsl:value-of select="AllocationDetails/UnitisedValue"/>
                </Field>
            </xsl:if>
            <Field ColumnName="tradcurref" IsQuoted="true">
                <xsl:value-of select="AllocationDetails/GrossAmount/Currency"/>
            </Field>
            <Field ColumnName="grosamt" IsQuoted="false">
                <xsl:value-of select="AllocationDetails/GrossAmount/Amount"/>
            </Field>
            <xsl:call-template name="charge">
                <xsl:with-param name="name">loctax</xsl:with-param>
                <xsl:with-param name="type">LocalTax</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="charge">
                <xsl:with-param name="name">locfee</xsl:with-param>
                <xsl:with-param name="type">LocalFee</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="charge">
                <xsl:with-param name="name">other</xsl:with-param>
                <xsl:with-param name="type">Other</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="charge">
                <xsl:with-param name="name">isschrg</xsl:with-param>
                <xsl:with-param name="type">Issuer</xsl:with-param>
            </xsl:call-template>

			<xsl:call-template name="commission">
                <xsl:with-param name="name">brkcomm</xsl:with-param>
                <xsl:with-param name="type">Broker</xsl:with-param>
            </xsl:call-template>
			
            <xsl:if test="boolean(AllocationDetails/InterestAmount/Amount)">
                <Field ColumnName="intamt" IsQuoted="false">
                    <xsl:value-of select="AllocationDetails/InterestAmount/Amount"/>
                </Field>
            </xsl:if>
            <Field ColumnName="netamt" IsQuoted="false">
                <xsl:value-of select="AllocationDetails/NetAmount/Amount"/>
            </Field>
            <Field ColumnName="setcurref" IsQuoted="true">
                <xsl:value-of select="AllocationDetails/SettlementAmount/Currency"/>
            </Field>
            <Field ColumnName="setamt" IsQuoted="false">
                <xsl:value-of select="AllocationDetails/SettlementAmount/Amount"/>
            </Field>

            <!-- Related -->

            <xsl:call-template name="yesnoField">
                <xsl:with-param name="name">rebook</xsl:with-param>
                <xsl:with-param name="value" select="Related/Rebooked"/>
            </xsl:call-template>
            <xsl:if test="boolean(Related/RebookedIdentifier)">
                <Field ColumnName="origomsref" IsQuoted="true">
                    <xsl:value-of select="Related/RebookedIdentifier"/>
                </Field>
            </xsl:if>

            <Field ColumnName="sysrev" IsQuoted="false">1</Field>
            <Field ColumnName="processing" IsQuoted="true">N</Field>

            <xsl:if test="boolean(AllocationDetails/Alert)">

                <Field ColumnName="alertctrycode" IsQuoted="true">
                    <xsl:value-of select="AllocationDetails/Alert/AlertCountryCode"/>
                </Field>
                <Field ColumnName="alertmethtype" IsQuoted="true">
                    <xsl:value-of select="AllocationDetails/Alert/AlertMethodType"/>
                </Field>
                <Field ColumnName="alertsectype" IsQuoted="true">
                    <xsl:value-of select="AllocationDetails/Alert/AlertSecurityType"/>
                </Field>
            </xsl:if>
            <xsl:if test="boolean(AllocationDetails/PlaceOfSafekeeping)">
                <Field ColumnName="clrmeth" IsQuoted="true">
                    <xsl:value-of select="AllocationDetails/PlaceOfSafekeeping"/>
                </Field>
            </xsl:if>			
            <xsl:if test="boolean(AllocationDetails/FundCurrency)">
                <Field ColumnName="fundcurref" IsQuoted="true">
                    <xsl:value-of select="AllocationDetails/FundCurrency"/>
                </Field>
            </xsl:if>
        </Record>
        </SALERIODatabase>
    </xsl:template>
    <xsl:template name="source">
        <xsl:param name="name"/>
        <Field>
            <xsl:attribute name="ColumnName">
                <xsl:value-of select="$name"/>
            </xsl:attribute>
            <xsl:attribute name="IsQuoted">true</xsl:attribute>
            <xsl:choose>
                <xsl:when test="boolean(OrderManagementSystem/Reference)">
                    <xsl:value-of select="OrderManagementSystem/Reference"/>
                </xsl:when>
                <xsl:otherwise>LOCAL</xsl:otherwise>
            </xsl:choose>
        </Field>
    </xsl:template>

    <xsl:template name="securityReference">
        <xsl:param name="name"/>
        <xsl:param name="type"/>
        <xsl:if test="ExecutionDetails/Security/References/Reference[@Type=$type]">
            <Field>
                <xsl:attribute name="ColumnName">
                    <xsl:value-of select="$name"/>
                </xsl:attribute>
                <xsl:attribute name="IsQuoted">true</xsl:attribute>
                <xsl:value-of select="ExecutionDetails/Security/References/Reference[@Type=$type]"/>
            </Field>
        </xsl:if>
    </xsl:template>

    <xsl:template name="genericSecurityReference">
        <xsl:param name="value"/>
        <xsl:param name="type"/>
        <Field ColumnName="secref" IsQuoted="true">
            <xsl:value-of select="$value"/>
        </Field>
        <Field ColumnName="secreftyp" IsQuoted="true">
            <xsl:value-of select="$type"/>
        </Field>
    </xsl:template>

    <xsl:template name="charge">
        <xsl:param name="name"/>
        <xsl:param name="type"/>
        <xsl:if test="AllocationDetails/Charges/Charge[@Type=$type]/Amount">
            <Field>
                <xsl:attribute name="ColumnName">
                    <xsl:value-of select="$name"/>
                </xsl:attribute>
                <xsl:attribute name="IsQuoted">false</xsl:attribute>
                <xsl:value-of select="AllocationDetails/Charges/Charge[@Type=$type]/Amount"/>
            </Field>
        </xsl:if>
    </xsl:template>

	
    <xsl:template name="commission">
        <xsl:param name="name"/>
        <xsl:param name="type"/>
        <xsl:if test="AllocationDetails/Commissions/Commission[@Type=$type]/Amount">
            <Field>
                <xsl:attribute name="ColumnName">
                    <xsl:value-of select="$name"/>
                </xsl:attribute>
                <xsl:attribute name="IsQuoted">false</xsl:attribute>
                <xsl:value-of select="AllocationDetails/Commissions/Commission[@Type=$type]/Amount"/>
            </Field>
			<xsl:variable name="hardsoft">
                <xsl:value-of select="AllocationDetails/Commissions/Commission[@Type=$type]/CommissionType"/>
            </xsl:variable>
            <Field ColumnName="hardsoft" IsQuoted="true">
                <xsl:choose>
                    <xsl:when test="$hardsoft = 'Soft'">S</xsl:when>
                    <xsl:otherwise>H</xsl:otherwise>
                </xsl:choose>
            </Field>
			<xsl:if test="AllocationDetails/Commissions/Commission[@Type=$type]/SoftType">
				<xsl:variable name="softtype">
					<xsl:value-of select="AllocationDetails/Commissions/Commission[@Type=$type]/SoftType"/>
				</xsl:variable>
				<Field ColumnName="commtyp" IsQuoted="true">
					<xsl:choose>
						<xsl:when test="$softtype = 'Introduced Brokerage'">INBR</xsl:when>
						<xsl:when test="$softtype = 'Commission Recapture'">CREC</xsl:when>
						<xsl:when test="$softtype = 'Share Arrangement'">CSHA</xsl:when>
						<xsl:when test="$softtype = 'Independent Research'">INRE</xsl:when>
						<xsl:otherwise>H</xsl:otherwise>
					</xsl:choose>
				</Field>
			</xsl:if>				
        </xsl:if>
    </xsl:template>
    <xsl:template name="brk_commission">
        <xsl:param name="name"/>
        <xsl:param name="type"/>
        <xsl:if test="ExecutionDetails/Commissions/Commission[@Type=$type]/Amount">
            <Field>
                <xsl:attribute name="ColumnName">
                    <xsl:value-of select="$name"/>
                </xsl:attribute>
                <xsl:attribute name="IsQuoted">false</xsl:attribute>
                <xsl:value-of select="ExecutionDetails/Commissions/Commission[@Type=$type]/Amount"/>
            </Field>
        </xsl:if>
    </xsl:template>

    <!-- Templates related to the database -->

    <xsl:template name="chardateField">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <Field>
            <xsl:attribute name="ColumnName">
                <xsl:value-of select="$name"/>
            </xsl:attribute>
            <xsl:attribute name="IsQuoted">true</xsl:attribute>
            <xsl:value-of select="translate($value, '-', '')"/>
        </Field>
    </xsl:template>

    <xsl:template name="yesnoField">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <Field>
            <xsl:attribute name="ColumnName">
                <xsl:value-of select="$name"/>
            </xsl:attribute>
            <xsl:attribute name="IsQuoted">true</xsl:attribute>
            <xsl:choose>
                <xsl:when test="$value = 'Yes'">Y</xsl:when>
                <xsl:otherwise>N</xsl:otherwise>
            </xsl:choose>
        </Field>
    </xsl:template>

    <xsl:template name="quantityType">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <Field>
            <xsl:attribute name="ColumnName">
                <xsl:value-of select="$name"/>
            </xsl:attribute>
            <xsl:attribute name="IsQuoted">true</xsl:attribute>
            <xsl:choose>
                <xsl:when test="$value = 'Unit'">Y</xsl:when>
                <xsl:otherwise>N</xsl:otherwise>
            </xsl:choose>
        </Field>
    </xsl:template>

</xsl:stylesheet>
