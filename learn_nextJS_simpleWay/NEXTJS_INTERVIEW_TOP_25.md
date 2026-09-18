# 🎯 Top 25 Next.js Interview Questions & Answers
### Essential Interview Prep for Freshers & Full-Stack Developers
*Instructor: AI Tech Teaching Mentor*
*Location: `/Users/amitraj/tradeBOT/LEARNING_Tech_website/learn_nextJS_simpleWay`*

---

### Q1: What is Next.js and how does it differ from React?
**Answer:** React is a client-side JavaScript UI library. Next.js is a full-stack production React framework built by Vercel. Next.js extends React by providing Server-Side Rendering (SSR), Static Site Generation (SSG), file-system routing, API Route Handlers, automatic image/font optimization, and Server Components out of the box with zero manual Webpack configuration.

---

### Q2: What is the difference between the App Router and the Pages Router?
**Answer:**
- **Pages Router (`pages/` directory):** The legacy Next.js routing system introduced in early versions. Relies on `getServerSideProps` and `getStaticProps` for data fetching. All components are rendered on client after hydration.
- **App Router (`app/` directory):** Modern routing system introduced in Next.js 13+. Built on React Server Components (RSC) and React Suspense. Features nested layouts, streaming, Server Actions, and colocation of data fetching directly inside components using `async/await`.

---

### Q3: Explain the difference between Server Components and Client Components in App Router.
**Answer:**
- **Server Components (Default):** Render exclusively on the server. They send zero JavaScript to the client bundle, can query databases directly, and keep API secrets secure. They cannot use browser APIs or React hooks (`useState`, `useEffect`).
- **Client Components (`'use client'`):** Rendered on the server initially for HTML and hydrated on the client. They support user interactivity, event listeners (`onClick`), and state hooks.

---

### Q4: What is Hydration and what causes a Hydration Error?
**Answer:** Hydration is the process where React attaches event listeners to server-rendered HTML in the browser to make it interactive.
A **Hydration Error** occurs when the HTML generated on the server does not match the HTML generated on the initial client render (e.g. rendering `new Date().toLocaleTimeString()` or checking `typeof window !== 'undefined'` directly inside JSX).

---

### Q5: What are Server Actions in Next.js?
**Answer:** Server Actions are asynchronous functions marked with `'use server'` that execute on the server. They allow form submissions and data mutations directly from React components without needing to define an explicit REST API endpoint.

---

### Q6: Explain ISR (Incremental Static Regeneration).
**Answer:** ISR allows you to update static pages in the background without rebuilding your entire website. By setting a revalidation time (e.g., `export const revalidate = 60;`), Next.js serves the cached static page and automatically regenerates a fresh version in the background when traffic arrives after the interval.

---

### Q7: What is the purpose of `layout.tsx` vs `template.tsx`?
**Answer:**
- `layout.tsx`: Wraps pages and persists across route transitions. It **does NOT remount** and preserves its state when navigating between child routes.
- `template.tsx`: Similar to layout, but **creates a new instance (remounts)** on each route navigation, resetting state and triggering enter animations.

---

### Q8: What are Route Handlers and how do they replace API Routes?
**Answer:** In the App Router, Route Handlers (`route.ts`) replace old `pages/api` routes. They are defined using standard Web `Request` and `Response` APIs and export HTTP verb functions: `GET`, `POST`, `PUT`, `DELETE`, `PATCH`.

---

### Q9: What is Middleware in Next.js?
**Answer:** Middleware (`middleware.ts`) runs at the Edge before a request is completed. It allows inspecting and modifying incoming requests and headers, redirecting unauthenticated users, rewriting URLs, and setting cookies.

---

### Q10: How does `next/image` optimize images compared to standard HTML `<img>`?
**Answer:**
1. **Format Optimization:** Automatically converts images to modern WebP/AVIF formats based on browser support.
2. **Visual Stability:** Prevents Cumulative Layout Shift (CLS) by requiring explicit width/height or fill.
3. **Lazy Loading:** Automatically loads images only when they enter the user's viewport.
4. **Responsive Sizing:** Generates responsive `srcset` tailored to the device screen size.
