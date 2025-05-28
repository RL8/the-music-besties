# Music Ranker Database Guide

This guide explains how the Music Ranker application interacts with the Supabase database, how to run the database scripts, and answers frequently asked questions.

## Critical User-Only Responsibilities

The following actions can **ONLY** be performed by the human user. The AI assistant **CANNOT** perform these actions under any circumstances:

### Database Access and Execution
- **Execute any SQL queries or scripts against the actual database**
- **Access the Supabase dashboard or admin interface**
- **Provide or enter database credentials and passwords**
- **Connect to the database using psql or other tools**

### Data Protection
- **Back up the database before making schema changes** (CRITICAL)
- **Restore database from backups if needed**
- **Handle sensitive data and ensure compliance with privacy regulations**
- **Delete production data or tables**

### Account Management
- **Create and manage the Supabase project and account**
- **Set up environment variables with database credentials**
- **Manage API keys and service roles**
- **Pay for database hosting and services**

### Authorization
- **Approve any significant database schema changes**
- **Make final decisions about data structure and relationships**
- **Grant permissions to database users**
- **Configure Row Level Security policies**

Remember: While the AI assistant can provide guidance, code, and SQL scripts, it has no ability to execute anything directly against your database. All execution must be done by you.

## How the App Accesses the Database

### Connection Setup

The Music Ranker application connects to Supabase using environment variables defined in the `.env` file:

```
VUE_APP_SUPABASE_URL=https://zfujellgwbznmosjuenq.supabase.co
VUE_APP_SUPABASE_ANON_KEY=your_anon_key
VUE_APP_SUPABASE_SERVICE_KEY=your_service_key
```

These credentials are loaded by the application and used to initialize the Supabase client in `src/lib/supabase/client.js`:

```javascript
import { createClient } from '@supabase/supabase-js'
import { SUPABASE_URL, SUPABASE_ANON_KEY } from '../../utils/env'

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    persistSession: true,
    autoRefreshToken: true
  }
});

export { supabase };
```

### Service Layer

The application uses a service layer to abstract database operations. This is implemented in `src/services/supabaseService.js`. The service provides methods for:

- Fetching albums, artists, songs, and recordings
- Adding, updating, and deleting records
- Managing user ratings and rankings

Example of how the app fetches albums:

```javascript
// In a Vue component
import { supabaseService } from '@/services/supabaseService'

async function loadAlbums() {
  try {
    const albums = await supabaseService.albums.getAll()
    // Process albums data
  } catch (error) {
    console.error('Error loading albums:', error)
  }
}
```

### Static vs. Database Data

The application was initially built using static JSON data (`src/data/static-albums.json`) for testing purposes. The transition to using the Supabase database involves:

1. Ensuring the database schema matches the expected structure
2. Updating components to use the supabaseService instead of importing static JSON
3. Implementing proper error handling and loading states

## Running Database Scripts

### Prerequisites

To run the database scripts, you need:

1. PostgreSQL client installed (psql)
2. Supabase database credentials

### Connecting to the Database

Connect to the Supabase PostgreSQL database using:

```bash
psql -h db.zfujellgwbznmosjuenq.supabase.co -p 5432 -d postgres -U postgres
```

When prompted, enter your database password from the Supabase dashboard.

### Examining Database Structure

To examine the database structure, use the scripts in the `scripts` folder:

1. **Get Table Structure**:
   ```sql
   \i database/scripts/get-table-structure.sql
   ```
   This shows all tables and their columns.

2. **Examine Data**:
   ```sql
   \i database/scripts/examine-data.sql
   ```
   This shows sample data and relationships between tables.

### Running Migrations

To apply database migrations:

1. Review the migration file in the `migrations` folder
2. Connect to the database using psql
3. Run the migration:
   ```sql
   \i database/migrations/001_initial_schema.sql
   ```

### Schema Expansion

To expand the database schema with new features:

1. Review the `schema-expansion.sql` file in the database folder
2. Back up your database using the Supabase dashboard or pgdump
3. Connect to the database using psql:
   ```bash
   psql -h db.zfujellgwbznmosjuenq.supabase.co -p 5432 -d postgres -U postgres
   ```
4. Once connected to the psql terminal, run the expansion script using the full path:
   ```sql
   \i C:/Users/Bravo/CascadeProjects/ts4apr/music-ranker/database/schema-expansion.sql
   ```
   
   Alternatively, if you're running psql from the project root directory:
   ```sql
   \i database/schema-expansion.sql
   ```

The schema expansion can also be run directly in the Supabase dashboard:
1. Log in to the [Supabase dashboard](https://app.supabase.com/)
2. Select your project
3. Go to the "SQL Editor" section
4. Create a new query
5. Copy and paste the contents of the `schema-expansion.sql` file
6. Click "Run" to execute the script

## Frequently Asked Questions

### How do I add new tables to the database?

1. Create a new migration file in the `migrations` folder with a sequential number
2. Write the SQL to create the new tables
3. Connect to the database and run the migration
4. Update the TypeScript type definitions in `src/types/database.ts`
5. Add new methods to the supabaseService to interact with the new tables

### How do I migrate from static JSON data to the database?

1. Ensure your database schema matches the structure of your static data
2. Create a script to import the static data into the database:
   ```javascript
   const staticData = require('./src/data/static-albums.json')
   const { supabase } = require('./src/lib/supabase/client')
   
   async function importData() {
     for (const album of staticData) {
       await supabase.from('Albums').insert({
         albumId: album.id,
         albumTitle: album.title,
         // Map other fields
       })
     }
   }
   ```
3. Update your components to use supabaseService instead of importing the static JSON

### Why are some database fields stored as text instead of other data types?

The current schema uses text fields for dates and IDs for flexibility and compatibility with the existing data structure. In a future schema update, these could be converted to more appropriate types like:

- `releaseDate` → date or timestamp
- `albumId`, `songId`, etc. → uuid

### How do I handle database errors in the application?

The supabaseService includes error handling, but you should also implement error handling in your components:

```javascript
try {
  const data = await supabaseService.albums.getAll()
  this.albums = data
} catch (error) {
  this.errorMessage = 'Failed to load albums'
  console.error('Error:', error)
}
```

### How do I debug database connection issues?

1. Check that your `.env` file contains the correct credentials
2. Use the `supabase-test.html` page in the public folder to test the connection
3. Check the browser console for any Supabase-related errors
4. Verify that the database is accessible by connecting with psql

### How can I optimize database queries for better performance?

1. Use appropriate indexes on frequently queried columns
2. Limit the number of records returned with `limit`
3. Only select the columns you need instead of using `select *`
4. Use RLS (Row Level Security) policies to filter data at the database level
5. Consider using Supabase's realtime features for live updates instead of polling

### Can I use the Supabase dashboard to manage the database?

Yes, you can use the Supabase dashboard to:
- View and edit data
- Run SQL queries
- Manage users and authentication
- Monitor database performance
- Set up Row Level Security policies

Access the dashboard at https://app.supabase.com/ and select your project.

## Database Operations: AI Limitations and User Requirements

This section highlights the specific limitations of the AI assistant for each database operation and what only the human user can do.

### Querying the Database

| Operation | AI Assistant Limitation | User Requirement |
|-----------|-------------------------|------------------|
| Connecting to the database | **Cannot connect** to any database | **Must establish all connections** using credentials |
| Executing SQL queries | **Cannot run** any queries | **Must execute** all queries via psql or Supabase dashboard |
| Viewing query results | **Cannot see** actual database content | **Must share results** if AI assistance is needed |
| Handling sensitive data | **Cannot access** protected information | **Must ensure** data privacy and compliance |

### Modifying Database Schema

| Operation | AI Assistant Limitation | User Requirement |
|-----------|-------------------------|------------------|
| Database backups | **Cannot create or access** backups | **Must backup** before any schema changes (CRITICAL) |
| Executing migrations | **Cannot run** migration scripts | **Must execute** all schema changes |
| Testing schema changes | **Cannot verify** in production | **Must test** changes in appropriate environments |
| Rollback procedures | **Cannot perform** rollbacks | **Must be prepared** to restore from backup if needed |

### Data Migration

| Operation | AI Assistant Limitation | User Requirement |
|-----------|-------------------------|------------------|
| Accessing external data sources | **Cannot connect** to external systems | **Must provide** access or data exports |
| Running migration scripts | **Cannot execute** data transfers | **Must run** all migration processes |
| Handling data validation errors | **Cannot fix** data issues directly | **Must resolve** any data integrity problems |
| Sensitive data transformation | **Cannot process** PII or sensitive data | **Must handle** all sensitive data transformations |

### Database Maintenance

| Operation | AI Assistant Limitation | User Requirement |
|-----------|-------------------------|------------------|
| Database monitoring | **Cannot access** performance metrics | **Must monitor** database health and performance |
| Security implementation | **Cannot configure** security settings | **Must implement** all security policies |
| Backup verification | **Cannot verify** backup integrity | **Must ensure** backups are valid and restorable |
| Resource management | **Cannot allocate** database resources | **Must manage** database scaling and resources |

### Troubleshooting

| Operation | AI Assistant Limitation | User Requirement |
|-----------|-------------------------|------------------|
| Direct database debugging | **Cannot directly debug** database issues | **Must perform** all direct diagnostic actions |
| Credential issues | **Cannot fix** authentication problems | **Must manage** all credentials and access |
| Network connectivity | **Cannot diagnose** network issues | **Must ensure** proper network configuration |
| Service interruptions | **Cannot restart** database services | **Must handle** all service management |

The AI assistant can provide guidance, scripts, and code examples, but the execution of any database operation is entirely the responsibility of the human user.
