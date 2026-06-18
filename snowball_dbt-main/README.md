# Snowball_dbt ☃️

This is the central dbt project for building and managing data models across multiple environments- **Snowflake**, **Databricks**, and **SQL Server**. It uses dynamic macros and adapter dispatching to keep the logic centralized and environment-agnostic.

---

## 📚 Table of Contents

- [🚀 Prerequisites](#-prerequisites)
- [🛠️ Setup Instructions](#-setup-instructions)
- [✨ Features](#-features)
- [📌 Other Notables](#-other-notables)
- [📅 Upcoming Features](#-upcoming-features)
- [💬 Feedback](#-feedback)
- [📇 Contact](#-contact)

---

## 🚀 Prerequisites


Before you begin, ensure you have the following:

- ✅ dbt installed (`>= 1.7.0` recommended)
- ✅ Access and credentials to **Snowflake** / **Databricks** / **SQL Server**
- ✅ Python environment for dependency management

---

## 🛠️ Setup Instructions


### 1️⃣ Clone the Repository

```bash
git clone https://github.com/jmangroup/snowball_dbt.git
cd Snowball_dbt
```

### 2️⃣ Configure Your Environment

* ✍️ Update `profiles.yml` with your **target connection** (Snowflake, Databricks, or SQL Server).
* ✍️ Update `models/sources.yml` with your **source data details**.

### 3️⃣ Install Dependencies

```bash
dbt deps
```

### 4️⃣ Load Seed Files

```bash
dbt seed
```

Make sure your column mapping or lookup seed files are defined correctly under `/seeds`.

### 5️⃣ Validate Connection

```bash
dbt debug
```

Ensure all configurations are correct and your data warehouse is reachable.

### 6️⃣ Run Models

```bash
dbt run
```

This will build all dbt models and deploy them to your configured target.

---

## ✨ Features

* 🔄 **Adapter Dispatching for Environment-specific behavior handled via centralized macros.**
* 🧠 **Dynamic Column Selections**
* 🔁 **Centralized and flexible join macros.**
* 🧪 **Using seed files, mapping table loaded via dbt seed.**
* 🔧 **Easily customizable source Configuration for different raw data sources.**
---

## 📌 Other Notables

### 🔷 Source Data

* 📥 Represents your **raw revenue-related data**.
* Located in the configured source database (e.g., staging or landing zone).
* Define source access and structure in `models/sources.yml`.

### 🎯 Target Data

* 📤 Represents your **transformed and deployed tables**.
* Can point to production, sandbox, or testing environments.
* Define target connection info in `profiles.yml`.

> ⚠️ Ensure correct access rights before deploying models to the target environment.

---

## 📅 Upcoming Features

* 🔐 dev-container for easy deployment of code
* 📊 Compatibility with Redshift as well
* 📈 Power Bi integration to make report building possible in few hours
* 💻 GUI for choosing techstack and uploading column mapping file
* 📁 Test cases for all models making it easy to debug error and debug.

---

## 💬 Feedback

Found a bug? Have a suggestion?
👉 [Raise an issue](https://github.com/jmangroup/snowball_dbt/issues/new/choose) or start a discussion!

---

## 📇 Contact

* 👩‍💻 [Konduru Tharun](mailto:kondurutharun@jmangroup.com)
* 👩‍💻 [Vishal Verma](mailto:vishalverma@jmangroup.com)
* 👩‍💻 [Sanjai R](mailto:sanjair@jmangroup.com)
* 👩‍💻 [Bhavana](mailto:bhavanas@jmangroup.com)
 