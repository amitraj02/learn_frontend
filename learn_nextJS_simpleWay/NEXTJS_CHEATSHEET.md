# ⚡ Next.js Fast Reference Cheatsheet
### App Router, Special Files, Data Fetching & CLI Reference
*Location: `/Users/amitraj/tradeBOT/LEARNING_Tech_website/learn_nextJS_simpleWay`*

---

## 1. CLI Commands
```bash
# Create new application
npx create-next-app@latest my-app

# Development server (http://localhost:3000)
npm run dev

# Production build & start
npm run build
npm run start

# Run ESLint check
npm run lint
```

---

## 2. App Router Special Files

| File | Role | Can it be Server Component? |
| :--- | :--- | :--- |
| `layout.tsx` | Shared layout (Navbar, Footer) | Yes (Default) |
| `page.tsx` | Unique UI for route | Yes (Default) |
| `loading.tsx` | Loading skeleton fallback via React Suspense | Yes |
| `not-found.tsx` | 404 UI | Yes |
| `error.tsx` | Error boundary UI | **Must be Client (`'use client'`)** |
| `route.ts` | Backend REST API endpoint (`GET`, `POST`) | Server only |

---

## 3. Server vs Client Component Decision Matrix

| Capability | Server Component (Default) | Client Component (`'use client'`) |
| :--- | :---: | :---: |
| Fetch data directly from DB | ✅ YES | ❌ NO |
| Access backend resources (API keys, secrets) | ✅ YES | ❌ NO |
| Keep heavy libraries on server (0 JS bundle) | ✅ YES | ❌ NO |
| Use `useState`, `useReducer` | ❌ NO | ✅ YES |
| Add event listeners (`onClick`, `onChange`) | ❌ NO | ✅ YES |
| Use browser APIs (`window`, `localStorage`) | ❌ NO | ✅ YES |
| Use custom hooks with state | ❌ NO | ✅ YES |

---

## 4. Data Fetching & Caching Strategies
```tsx
// 1. Static (Default, cached indefinitely)
fetch(url, { cache: 'force-cache' });

// 2. Dynamic (SSR, fetch on every request)
fetch(url, { cache: 'no-store' });

// 3. Time-based Revalidation (ISR, every 60s)
fetch(url, { next: { revalidate: 60 } });

// 4. Tag-based on-demand revalidation
fetch(url, { next: { tags: ['stocks'] } });
// In a server action:
revalidateTag('stocks');
```

---

## 5. Route Handlers (`route.ts`) Quick Template
```ts
import { NextResponse, NextRequest } from 'next/server';

export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const id = searchParams.get('id');
  return NextResponse.json({ id, status: 'ok' });
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  return NextResponse.json({ received: body }, { status: 201 });
}
```
