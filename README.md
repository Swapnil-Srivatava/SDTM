
# SDTM Mapping and Clinical Data Standardization (SAS)

## Overview

This repository demonstrates the end-to-end process of transforming raw clinical trial–style data into **CDISC SDTM–compliant datasets** using **SAS**. The project focuses on applying standardized clinical data structures, controlled terminology, and traceable derivations consistent with industry expectations for regulatory submission and clinical reporting.

The goal of this project is to showcase **hands-on SDTM mapping, dataset creation, and documentation practices** as performed by a Statistical Programmer or SDTM Programmer in a clinical research setting.

---

## Objectives

- Convert raw clinical data into **SDTM-compliant domains**
- Apply **CDISC SDTM principles**, including domain structure, variable naming, and metadata consistency
- Demonstrate **traceable, reproducible SAS programming workflows**
- Produce standardized datasets suitable for downstream **ADaM or reporting** work

---

## Data Description

The raw datasets used in this project simulate clinical trial source data and include subject-level and event-level information typically encountered in Phase I–III studies.

Examples include:
- Demographics
- Adverse events
- Exposure or treatment data
- Other subject-level observations

All datasets are processed with the assumption of **regulatory-grade data quality expectations**, including consistency checks and transparent derivations.

---

## SDTM Domains Created

The project includes the creation and validation of the following SDTM domains (as applicable):

- **DM** – Demographics  
- **AE** – Adverse Events  
- **EX** – Exposure  
- Additional domains based on available source data

Each domain adheres to:
- CDISC SDTM variable naming conventions
- Proper domain structure and variable ordering
- Controlled terminology where required
- Clearly documented derivation logic

---

## Programming Approach

- **Language:** SAS  

### Methodology
- Read and clean raw source datasets  
- Map source variables to SDTM variables  
- Derive required SDTM variables (e.g., `STUDYID`, `DOMAIN`, `USUBJID`)  
- Apply controlled terminology and formats  
- Output finalized SDTM datasets with validation checks  

Programs emphasize:
- Readability and maintainability  
- Modular structure  
- Clear commenting for reviewer traceability  
- Reproducibility of results  

---

## Quality Control and Validation

Basic QC checks are incorporated to ensure:
- Dataset completeness  
- Variable consistency  
- Domain-level integrity  
- Correct population of required SDTM variables  

This mirrors standard SDTM programming workflows where datasets undergo internal review prior to submission or downstream analysis.

---

## Skills Demonstrated

- SDTM domain knowledge  
- Clinical SAS programming  
- CDISC standards application  
- Data cleaning and transformation  
- Reproducible and auditable programming practices  
- Documentation for regulatory workflows  

---

## Intended Audience

This project is intended to demonstrate readiness for roles such as:

- **Statistical Programmer I / II**
- **Clinical SAS Programmer**
- **SDTM Programmer**
- **Junior Biostatistician / Programmer**

It reflects the type of work performed in clinical research organizations, CROs, and pharmaceutical companies supporting regulatory submissions.

---

## Notes

This project is for educational and portfolio demonstration purposes only and does not use real patient data.

