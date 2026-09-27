# 💳 Fintech Project Management Analysis

A European fintech company builds payment products (e-wallets, tap-to-pay, payment APIs) and runs many projects at once. Some finish late, some go over budget. This project uses the company's project data to find out **what is going wrong and what managers should change**.

Each part answers a request from a manager, in their own words. For every request I follow the same five steps: **understand** the decision, **plan** the questions, **query**, state the **insight**, and **recommend** (including what the data can't prove).

**Tools:** PostgreSQL + DBeaver (all data work) · Tableau Public (dashboard)

---

## 📊 Progress

| Part | Who's asking | Topic | Status |
|---|---|---|---|
| 1 | *(me)* | Set up the database and import the data | ✅ Done |
| 2 | Data Engineering Lead | Check the data and clean it | ⏳ Next |
| 3 | CFO | Budget: which projects waste money? | — |
| 4 | Head of PMO | Delays: where do they come from? | — |
| 5 | VP Engineering | People: seniors or juniors? | — |
| 6 | COO | Teams and locations: where to rebalance? | — |
| 7 | Chief Risk Officer | Do our risk ratings mean anything? | — |
| 8 | CEO | Tableau dashboard + final recommendations | — |

---

## 🗂️ The data

The data came as one Excel workbook with 5 sheets, each exported to a CSV.

| Table | Rows | One row is... |
|---|---|---|
| `departments` | 7 | a department and its head |
| `projects` | 72 | a project: budget, dates, status, risk level, completion % |
| `employees` | 120 | a person: department, role, experience level, hourly rate |
| `tasks` | 624 | a task inside a project: planned vs actual hours, status, priority, assignee |
| `milestones` | 288 | a project checkpoint: planned vs actual date |

A separate flags file (country flag image links) is only for decorating the dashboard. It will be added in Part 8.

---

## Part 1 · Set up the database ✅

📄 [`SQL/00_setup_and_import.sql`](SQL/00_setup_and_import.sql)

**Design: two layers in the database `fintech_pm`**

- **`raw`**: the CSVs exactly as they arrived. Every column is `TEXT`, and this layer is never edited.
- **`clean`**: the typed, fixed version used for all analysis (built in Part 2).

In my previous project I fixed data with `UPDATE` on the only copy, so a mistake could not be undone. With two layers, `clean` can always be rebuilt from `raw`.

**Why every raw column is `TEXT`:** the dates are in `DD/MM/YYYY` format. Loaded straight into a `DATE` column, PostgreSQL would read `04/10/2025` as 10 April instead of 4 October, and would reject `26/09/2025` outright (there is no month 26). Storing text first and converting in Part 2, with the format stated explicitly, avoids both problems.

**Checks**

| Check | Result |
|---|---|
| Row counts match the source | ✅ 7 · 120 · 72 · 624 · 288 |
| No empty ID in any table | ✅ 0 NULL IDs in all 5 tables |

**Problems I hit and fixed**

- **DBeaver matches CSV columns by name, not by position.** Headers that only differed in capital letters (`Role` → `role`) loaded correctly. Others (`EmployeeID` → `employee_id`) were skipped or added as new columns, which left my columns full of NULLs while the row count still looked right. The fix was to recreate the table and map every column by hand on the import screen. That's why the second check above exists: a correct row count alone doesn't prove the import worked.
- **`COPY` was blocked by macOS**, which doesn't let the PostgreSQL server read files on the Desktop. I switched to DBeaver's import.

---

## ▶️ How to rebuild

1. Create the database once: `CREATE DATABASE fintech_pm;`
2. Run sections 1–2 of `00_setup_and_import.sql` (schemas and raw tables).
3. Import each CSV with DBeaver: right-click the table → *Import Data* → CSV. On the mapping screen, every column must say **existing**. Tick *Truncate target table before load*.
4. Run section 4 (checks): the row counts must match and the NULL-ID counts must be 0.
5. Run the remaining SQL files in order.

---

## 📁 Repo structure

```
fintech-project-analysis/
├── README.md
├── data/
│   ├── departments.csv
│   ├── projects.csv
│   ├── employees.csv
│   ├── tasks.csv
│   └── milestones.csv
└── SQL/
    └── 00_setup_and_import.sql
```
