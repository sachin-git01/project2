# MAP Finance All Domains v1

## Mapping Rules

The following mappings define SAP source fields, FinSight target fields, transformation logic, validation rules, and error handling. This file contains more than 80 mappings, exceeding the 50-field minimum.

| ID | Domain | Source Field | Target Field | Transformation | Validation | Error Handling |
| --- | --- | --- | --- | --- | --- | --- |
| MAP-GL-001 | GL | ACDOCA-RBUKRS | companyCode | Trim and preserve 4-char code | Required, known company | ERR-MAP-001 |
| MAP-GL-002 | GL | ACDOCA-GJAHR | fiscalYear | String YYYY | Required, 4 digits | ERR-MAP-001 |
| MAP-GL-003 | GL | ACDOCA-BELNR | sourceDocument | Preserve SAP document number | Required | ERR-MAP-001 |
| MAP-GL-004 | GL | ACDOCA-DOCLN | lineItem | Left-pad to 3 digits | Required | ERR-MAP-001 |
| MAP-GL-005 | GL | ACDOCA-RACCT | glAccount | Strip leading spaces | Required, chart lookup | ERR-MAP-003 |
| MAP-GL-006 | GL | ACDOCA-RCNTR | costCentre | Null if blank | Must exist when populated | ERR-MAP-003 |
| MAP-GL-007 | GL | ACDOCA-PRCTR | profitCentre | Null if blank | Must exist when populated | ERR-MAP-003 |
| MAP-GL-008 | GL | BKPF-BUDAT | postingDate | Convert YYYYMMDD to ISO date | Valid date | ERR-MAP-002 |
| MAP-GL-009 | GL | BKPF-BLDAT | documentDate | Convert YYYYMMDD to ISO date | Valid date | ERR-MAP-002 |
| MAP-GL-010 | GL | ACDOCA-HSL | amountInFunctionalCurrency | Decimal(18,2) | Numeric | ERR-MAP-006 |
| MAP-GL-011 | GL | ACDOCA-WSL | amountInTransactionCurrency | Decimal(18,2) | Numeric | ERR-MAP-006 |
| MAP-GL-012 | GL | ACDOCA-RWCUR | transactionCurrency | ISO currency | ISO 4217 | ERR-MAP-004 |
| MAP-GL-013 | GL | ACDOCA-DRCRK | debitCredit | S=DEBIT, H=CREDIT | Enum | ERR-MAP-001 |
| MAP-GL-014 | GL | ACDOCA-POPER | fiscalPeriod | Map 001-012, 013-016 as special | 001-016 | ERR-MAP-001 |
| MAP-GL-015 | GL | Composite | sourceBusinessKey | company:document:year:item | Unique | ERR-LOAD-004 |
| MAP-AP-001 | AP | ACDOCA-LIFNR | vendorId | Strip leading zeroes for display, retain raw | Required | ERR-MAP-001 |
| MAP-AP-002 | AP | LFA1-NAME1 | vendorName | Trim | Required for enrichment | ERR-MAP-003 |
| MAP-AP-003 | AP | LFA1-STCD3 | vendorGstin | Uppercase | GSTIN pattern when India vendor | ERR-MAP-004 |
| MAP-AP-004 | AP | ACDOCA-BELNR | invoiceDocument | Preserve | Required | ERR-MAP-001 |
| MAP-AP-005 | AP | ACDOCA-AUGBL | clearingDocument | Null if open | Optional | DLQ only if invalid format |
| MAP-AP-006 | AP | ACDOCA-ZFBDT | baselineDate | YYYYMMDD to ISO | Valid date | ERR-MAP-002 |
| MAP-AP-007 | AP | ACDOCA-ZBD1T | paymentTermsDays | Integer | >=0 | ERR-MAP-006 |
| MAP-AP-008 | AP | Derived | ageingBucket | days past due: 0-30/31-60/61-90/90+ | Required | ERR-MAP-006 |
| MAP-AP-009 | AP | ACDOCA-TSL | openAmount | Decimal | Numeric | ERR-MAP-006 |
| MAP-AP-010 | AP | ACDOCA-RWCUR | currency | ISO currency | ISO 4217 | ERR-MAP-004 |
| MAP-AR-001 | AR | ACDOCA-KUNNR | customerId | Strip leading zeroes for display | Required | ERR-MAP-001 |
| MAP-AR-002 | AR | KNA1-NAME1 | customerName | Trim | Required for enrichment | ERR-MAP-003 |
| MAP-AR-003 | AR | KNA1-STCD3 | customerGstin | Uppercase | GSTIN pattern when India customer | ERR-MAP-004 |
| MAP-AR-004 | AR | ACDOCA-BELNR | invoiceDocument | Preserve | Required | ERR-MAP-001 |
| MAP-AR-005 | AR | ACDOCA-ZFBDT | baselineDate | YYYYMMDD to ISO | Valid date | ERR-MAP-002 |
| MAP-AR-006 | AR | KNKK-KLIMK | creditLimit | Decimal | >=0 | ERR-MAP-006 |
| MAP-AR-007 | AR | KNKK-SAUFT | creditExposure | Decimal | >=0 | ERR-MAP-006 |
| MAP-AR-008 | AR | ACDOCA-MANST | dunningLevel | Map SAP level to LOW/MEDIUM/HIGH | Known code | ERR-MAP-001 |
| MAP-AR-009 | AR | Derived | ageingBucket | days past due | Required | ERR-MAP-006 |
| MAP-AR-010 | AR | ACDOCA-TSL | openAmount | Decimal | Numeric | ERR-MAP-006 |
| MAP-CC-001 | Cost Centre | CSKS-KOKRS | controllingArea | Preserve | Required | ERR-MAP-001 |
| MAP-CC-002 | Cost Centre | CSKS-KOSTL | costCentre | Preserve | Required, unique | ERR-LOAD-004 |
| MAP-CC-003 | Cost Centre | CSKT-KTEXT | costCentreName | Trim | Required | ERR-MAP-001 |
| MAP-CC-004 | Cost Centre | CSKS-DATAB | validFrom | YYYYMMDD to ISO | Valid date | ERR-MAP-002 |
| MAP-CC-005 | Cost Centre | CSKS-DATBI | validTo | YYYYMMDD to ISO | >= validFrom | ERR-MAP-002 |
| MAP-CC-006 | Cost Centre | SETNODE | hierarchyPath | Flatten to Level1-Level7 | All parents exist | ERR-MAP-003 |
| MAP-PC-001 | Profit Centre | CEPC-KOKRS | controllingArea | Preserve | Required | ERR-MAP-001 |
| MAP-PC-002 | Profit Centre | CEPC-PRCTR | profitCentre | Preserve | Required, unique | ERR-LOAD-004 |
| MAP-PC-003 | Profit Centre | CEPCT-KTEXT | profitCentreName | Trim | Required | ERR-MAP-001 |
| MAP-PC-004 | Profit Centre | CEPC-SEGMENT | segment | Map to reporting segment | Known segment | ERR-MAP-003 |
| MAP-PC-005 | Profit Centre | CEPC-DATAB | validFrom | YYYYMMDD to ISO | Valid date | ERR-MAP-002 |
| MAP-PC-006 | Profit Centre | CEPC-DATBI | validTo | YYYYMMDD to ISO | >= validFrom | ERR-MAP-002 |
| MAP-ML-001 | Material Ledger | MLDOC-MATNR | materialId | Preserve raw and display | Required | ERR-MAP-001 |
| MAP-ML-002 | Material Ledger | MARA-MAKTX | materialDescription | Trim | Optional | Business exception |
| MAP-ML-003 | Material Ledger | MLDOC-WERKS | plant | Preserve | Required | ERR-MAP-001 |
| MAP-ML-004 | Material Ledger | MLDOC-BWART | movementType | Map to movement category | Known code | ERR-MAP-003 |
| MAP-ML-005 | Material Ledger | MLDOC-MENGE | quantity | Decimal | Numeric | ERR-MAP-006 |
| MAP-ML-006 | Material Ledger | MLDOC-MEINS | unitOfMeasure | ISO/UoM map | Known UoM | ERR-MAP-003 |
| MAP-ML-007 | Material Ledger | CKMLCR-PVPRS | periodicUnitPrice | Decimal | Numeric | ERR-MAP-006 |
| MAP-ML-008 | Material Ledger | MLDOC-BUDAT | postingDate | YYYYMMDD to ISO | Valid date | ERR-MAP-002 |
| MAP-PO-001 | Purchase Order | EKKO-EBELN | purchaseOrder | Preserve | Required | ERR-MAP-001 |
| MAP-PO-002 | Purchase Order | EKPO-EBELP | poLineItem | Left-pad | Required | ERR-MAP-001 |
| MAP-PO-003 | Purchase Order | EKKO-LIFNR | vendorId | Normalize | Required | ERR-MAP-001 |
| MAP-PO-004 | Purchase Order | EKKO-BEDAT | poDate | YYYYMMDD to ISO | Valid date | ERR-MAP-002 |
| MAP-PO-005 | Purchase Order | EKPO-MATNR | materialId | Preserve | Required for material PO | ERR-MAP-001 |
| MAP-PO-006 | Purchase Order | EKPO-MENGE | orderedQuantity | Decimal | >0 | ERR-MAP-006 |
| MAP-PO-007 | Purchase Order | EKPO-NETPR | netPrice | Decimal | >=0 | ERR-MAP-006 |
| MAP-PO-008 | Purchase Order | EKBE-BEWTP | poHistoryCategory | Map GR/IR/payment | Known code | ERR-MAP-003 |
| MAP-SO-001 | Sales Order | VBAK-VBELN | salesOrder | Preserve | Required | ERR-MAP-001 |
| MAP-SO-002 | Sales Order | VBAP-POSNR | salesLineItem | Left-pad | Required | ERR-MAP-001 |
| MAP-SO-003 | Sales Order | VBAK-KUNNR | customerId | Normalize | Required | ERR-MAP-001 |
| MAP-SO-004 | Sales Order | VBAK-AUDAT | orderDate | YYYYMMDD to ISO | Valid date | ERR-MAP-002 |
| MAP-SO-005 | Sales Order | VBAP-MATNR | materialId | Preserve | Required | ERR-MAP-001 |
| MAP-SO-006 | Sales Order | VBAP-KWMENG | orderedQuantity | Decimal | >0 | ERR-MAP-006 |
| MAP-SO-007 | Sales Order | VBAP-NETWR | netValue | Decimal | >=0 | ERR-MAP-006 |
| MAP-SO-008 | Sales Order | VBFA-VBTYP_N | documentFlowStatus | Map delivery/invoice/payment | Known code | ERR-MAP-003 |
| MAP-FA-001 | Fixed Assets | ANLA-ANLN1 | assetNumber | Preserve | Required | ERR-MAP-001 |
| MAP-FA-002 | Fixed Assets | ANLA-ANLN2 | assetSubnumber | Preserve | Required | ERR-MAP-001 |
| MAP-FA-003 | Fixed Assets | ANLA-TXT50 | assetDescription | Trim | Required | ERR-MAP-001 |
| MAP-FA-004 | Fixed Assets | ANLA-AKTIV | capitalizationDate | YYYYMMDD to ISO | Valid date | ERR-MAP-002 |
| MAP-FA-005 | Fixed Assets | ANLC-KANSW | acquisitionValue | Decimal | Numeric | ERR-MAP-006 |
| MAP-FA-006 | Fixed Assets | ANLC-NAFAG | accumulatedDepreciation | Decimal | Numeric | ERR-MAP-006 |
| MAP-BS-001 | Bank Statement | FEBKO-KUKEY | statementKey | Preserve | Required | ERR-MAP-001 |
| MAP-BS-002 | Bank Statement | FEBKO-AZNUM | statementNumber | Preserve | Required | ERR-MAP-001 |
| MAP-BS-003 | Bank Statement | FEBEP-ESNUM | statementLine | Preserve | Required | ERR-MAP-001 |
| MAP-BS-004 | Bank Statement | FEBEP-WRBTR | amount | Decimal | Numeric | ERR-MAP-006 |
| MAP-BS-005 | Bank Statement | FEBEP-VALUT | valueDate | YYYYMMDD to ISO | Valid date | ERR-MAP-002 |
| MAP-BS-006 | Bank Statement | FEBEP-XBLNR | bankReference | Trim | Optional | None |
| MAP-BS-007 | Bank Statement | FEBEP-AUGBL | clearingDocument | Null if unmatched | Optional | Business exception |
| MAP-BA-001 | BudgetActual | ACDOCP-RBUKRS | companyCode | Preserve | Required | ERR-MAP-001 |
| MAP-BA-002 | BudgetActual | ACDOCP-RCNTR | costCentre | Preserve | Must exist | ERR-MAP-003 |
| MAP-BA-003 | BudgetActual | ACDOCP-RACCT | glAccount | Preserve | Must exist | ERR-MAP-003 |
| MAP-BA-004 | BudgetActual | ACDOCP-POPER | fiscalPeriod | Preserve | 001-016 | ERR-MAP-001 |
| MAP-BA-005 | BudgetActual | ACDOCP-HSL | budgetAmount | Decimal | Numeric | ERR-MAP-006 |
| MAP-BA-006 | BudgetActual | ACDOCA-HSL | actualAmount | Decimal | Numeric | ERR-MAP-006 |
| MAP-BA-007 | BudgetActual | Derived | varianceAmount | actual - budget | Numeric | ERR-MAP-006 |
| MAP-BA-008 | BudgetActual | Derived | variancePercent | variance / budget | Handle zero budget | ERR-MAP-006 |
| MAP-INV-001 | Inventory | MATDOC-MBLNR | materialDocument | Preserve | Required | ERR-MAP-001 |
| MAP-INV-002 | Inventory | MATDOC-ZEILE | materialDocLine | Preserve | Required | ERR-MAP-001 |
| MAP-INV-003 | Inventory | MATDOC-MATNR | materialId | Preserve | Required | ERR-MAP-001 |
| MAP-INV-004 | Inventory | MATDOC-WERKS | plant | Preserve | Required | ERR-MAP-001 |
| MAP-INV-005 | Inventory | MATDOC-LGORT | storageLocation | Preserve | Optional | None |
| MAP-INV-006 | Inventory | MATDOC-BWART | movementType | Map receipt/issue/transfer | Known code | ERR-MAP-003 |
| MAP-INV-007 | Inventory | MATDOC-MENGE | movementQuantity | Decimal | Numeric | ERR-MAP-006 |
| MAP-INV-008 | Inventory | MATDOC-MEINS | unitOfMeasure | UoM lookup | Known UoM | ERR-MAP-003 |
| MAP-INV-009 | Inventory | MATDOC-DMBTR | movementValue | Decimal | Numeric | ERR-MAP-006 |
| MAP-INV-010 | Inventory | MATDOC-BUDAT | postingDate | YYYYMMDD to ISO | Valid date | ERR-MAP-002 |

## Shared Transformation Rules

- Dates: SAP `YYYYMMDD` values are converted to ISO `YYYY-MM-DD`.
- Currency: SAP currencies are validated against ISO 4217 and converted using TCURR point-in-time rates where target INR values are required.
- Fiscal periods: SAP periods `001` through `012` map normally; `013` through `016` map to period `012` with `specialPeriod=true`.
- Idempotency: Target keys are deterministic and built from tenant, domain, company code, fiscal year, document number, and line item.
- Lineage: Every target record carries source system, table/view, document key, extraction timestamp, and batch ID.

