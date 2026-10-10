# Day 7 Assignment: Scaling a Photo-Sharing App

## 1. Assumptions and Daily Active Users

SnapShare is a photo-sharing application where users upload photos and view a feed containing photos from people they follow.

The following assumptions are used:

* Registered users: 10,000,000.
* Daily active users (DAU): 10% of registered users.
* Photos uploaded per active user per day: 1.
* Feed pages viewed per active user per day: 50.
* Average original photo size: 2 MB.
* Average thumbnail size: 50 KB.
* Seconds per day: 86,400.
* Days per year: 365.
* Peak traffic is estimated at five times the average traffic.
* All daily active users upload one photo and view 50 feed pages daily.
* Storage estimates use decimal units (1 TB = 1,000 GB) and exclude database overhead, backups, replication, and other application data.

**Daily active users calculation:**

DAU = 10,000,000 × 10% = **1,000,000 active users per day**.

## 2. Traffic and Storage Calculations

### A. Uploads per second

Each daily active user uploads one photo.

* Daily uploads = 1,000,000 × 1 = 1,000,000 photos.
* Average uploads per second = 1,000,000 ÷ 86,400.

**Average upload rate = approximately 11.57 uploads per second.**

### B. Feed views per second

Each daily active user views 50 feed pages.

* Daily feed views = 1,000,000 × 50 = 50,000,000 feed views.
* Average feed views per second = 50,000,000 ÷ 86,400.

**Average feed view rate = approximately 578.70 feed views per second.**

Using a peak multiplier of 5:

* Peak feed views per second = 578.70 × 5.

**Estimated peak feed view rate = approximately 2,894 feed views per second.**

These are average and estimated peak request rates; actual traffic may vary by time of day.

### C. Photo storage per year

Each upload creates an original photo and a thumbnail.

**Original photos:**

* Daily original-photo storage = 1,000,000 × 2 MB = 2,000,000 MB = 2 TB per day.
* Annual original-photo storage = 2 TB × 365 = **730 TB per year**.

**Thumbnails:**

* Daily thumbnail storage = 1,000,000 × 50 KB = 50,000,000 KB = 50 GB per day.
* Annual thumbnail storage = 50 GB × 365 = **18.25 TB per year**.

**Total annual photo storage:**

730 TB + 18.25 TB = **748.25 TB per year**.

This is the estimated raw storage for one copy of all original photos and thumbnails, assuming no deletion or compression beyond the stated average file sizes.

## 3. Is SnapShare Read-Heavy or Write-Heavy?

SnapShare is a **read-heavy system** because users view 50 feed pages per day but upload only one photo per day. This produces approximately 50 million feed views compared with 1 million uploads daily, so the system must prioritise fast feed delivery and efficient reads.

The design should use a CDN to serve image files close to users, a cache to reduce repeated database queries, and a database read replica to handle additional read traffic without overloading the primary database. The upload path should remain reliable and use background processing for thumbnail creation.

## 4. Why Photos Should Not Be Stored Inside the Database

Original photos and thumbnails should be stored in object storage rather than directly inside the database. Photo files are large binary objects that would increase database size, backups, network traffic, and query overhead if stored in database records. Object storage is designed for durable, scalable file storage, while the database should hold metadata such as photo IDs, owners, captions, timestamps, storage keys, and relationships between users.

The CDN can then deliver photos and thumbnails from object storage without sending every image request through the application servers.

## 5. Architecture Diagram

```text
                         USERS
                           |
                +----------+----------+
                |                     |
          Feed / API requests     Photo delivery
                |                     |
        +-------v--------+       +----v----+
        | Load Balancer  |       |   CDN   |
        +-------+--------+       +----+----+
                |                     |
        +-------v--------+       +----v---------+
        |  App Servers   |       | Object       |
        | (API services) |       | Storage      |
        +---+---------+--+       | Originals &  |
            |         |          | Thumbnails   |
            |         |          +--------------+
       +----v---+  +--v----------------+
       | Cache  |  | Primary Database  |
       | Redis  |  | Users & Metadata  |
       +--------+  +--------+----------+
                            |
                     +------v-------+
                     | Read Replica |
                     +--------------+

        Upload processing:
        App Servers
             |
             v
        +----+-----+
        | Job Queue|
        +----+-----+
             |
             v
        +----+------+
        | Thumbnail |
        | Worker    |
        +----+------+
             |
             v
        +----+----------------+
        | Object Storage      |
        | Save Thumbnail      |
        +---------------------+
```

## 6. What Each Component Does

1. **Users:** Upload photos and request their feeds and other users' photos.
2. **Load balancer:** Distributes incoming API requests across healthy application servers to prevent one server from becoming overloaded.
3. **App servers:** Authenticate users, validate uploads, manage feed requests, and coordinate database, cache, queue, and object-storage operations.
4. **Cache (Redis):** Stores frequently accessed feed data and metadata temporarily to reduce database load and improve response times.
5. **Primary database:** Stores persistent information such as user accounts, follows, photo metadata, and references to stored files.
6. **Database read replica:** Copies data from the primary database and handles suitable read queries to reduce pressure on the primary database.
7. **Object storage:** Stores original photos and generated thumbnails durably without placing large image files inside database records.
8. **CDN:** Caches and delivers image files from geographically distributed locations to reduce latency and object-storage traffic.
9. **Job queue:** Holds thumbnail-generation jobs so photo uploads can finish without waiting for image processing to complete.
10. **Thumbnail worker:** Retrieves queued jobs, creates smaller thumbnail images, and saves them to object storage.

## 7. Photo Upload Flow

1. The user selects a photo and submits it through the SnapShare application.
2. The load balancer routes the API request to a healthy application server.
3. The application server authenticates the user, validates the file type and size, and checks upload permissions.
4. The server arranges for the original photo to be uploaded to object storage, preferably through a short-lived, secure upload URL so large files do not have to pass through the application server.
5. After the upload succeeds, the application server saves the photo metadata and object-storage key in the primary database.
6. The server publishes a thumbnail-generation job to the job queue, including the photo ID and storage key.
7. The application confirms the upload to the user without waiting for the thumbnail to be created.
8. A thumbnail worker retrieves the job, downloads or reads the original photo from object storage, and generates a 50 KB thumbnail target.
9. The worker saves the thumbnail in object storage and updates the photo metadata or processing status in the database.
10. When users view the photo in a feed, the application returns the relevant metadata and image URLs, and the CDN serves the original or thumbnail where available.

If thumbnail processing fails, the job can be retried; the application should track processing status and avoid treating an unfinished thumbnail as ready.

## 8. Trade-Offs

### Trade-off 1: Cache speed versus data freshness

Caching feed data reduces database load and improves response times, but cached results may become temporarily outdated after a user uploads a photo or follows another user. SnapShare should use appropriate cache expiration and invalidation rules, accepting a small amount of staleness where immediate consistency is unnecessary.

### Trade-off 2: Asynchronous thumbnails versus immediate availability

Generating thumbnails in a background worker makes uploads faster and isolates image processing from normal API traffic, but the thumbnail may not be available immediately after upload. SnapShare should display a placeholder or the original photo until thumbnail generation finishes.

### Trade-off 3: Read replicas versus consistency

A read replica improves read capacity, but replication lag can mean that a recently uploaded photo does not immediately appear in a feed served from the replica. The application can direct critical read-after-write requests to the primary database while routing suitable general reads to the replica.

### Trade-off 4: CDN performance versus storage and invalidation complexity

A CDN reduces image-delivery latency and traffic reaching object storage, but cached images may require expiration or invalidation when content changes or is removed. Using unique, versioned image URLs simplifies cache management, while access controls and deletion procedures must account for cached copies.

## Conclusion

SnapShare should use a read-optimised architecture built around a CDN, horizontally scalable application servers, Redis caching, a primary database with a read replica, object storage, and asynchronous thumbnail processing. At the estimated scale of 1 million daily active users, 50 million daily feed views, and approximately 748.25 TB of new photo storage per year, these components help separate image delivery, metadata queries, and background processing so each can scale independently.
