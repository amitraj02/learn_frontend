# ⚡ JavaScript Fast Reference Cheatsheet
### Core Syntax, Array Methods, Async & ES6 Reference Card
*Location: `/Users/amitraj/tradeBOT/LEARNING_Tech_website/learn_javascript_simpleWay`*

---

## 1. Variables & Scope
```javascript
const PI = 3.14159;   // Block-scoped, immutable identifier
let counter = 0;      // Block-scoped, reassignable
```

## 2. Array Methods Quick Table

| Method | Returns | Mutates Original? | Common Use Case |
| :--- | :--- | :---: | :--- |
| `.map(fn)` | New Array | ❌ No | Transform items (`x * 2`) |
| `.filter(fn)` | New Array | ❌ No | Select matching items (`x > 10`) |
| `.reduce(fn, init)` | Single Value | ❌ No | Sum, average, group items |
| `.find(fn)` | Item / undefined | ❌ No | Find first matching element |
| `.findIndex(fn)` | Index / -1 | ❌ No | Get index of matching element |
| `.some(fn)` | Boolean | ❌ No | Does at least 1 item match? |
| `.every(fn)` | Boolean | ❌ No | Do all items match? |
| `.includes(val)`| Boolean | ❌ No | Check if primitive exists |
| `.push(val)` | New Length | ✅ Yes | Append to end |
| `.pop()` | Removed Item | ✅ Yes | Remove from end |

---

## 3. Destructuring & Spread
```javascript
// Object destructuring with rename and default:
const user = { name: "Amit", role: "Trader" };
const { name: fullName, age = 25 } = user;

// Array spread (shallow clone):
const copy = [...originalArray, newItem];

// Object spread (shallow clone & overwrite):
const updated = { ...originalObj, status: "ACTIVE" };
```

---

## 4. Modern Async / Await Template
```javascript
async function loadData(url) {
  try {
    const res = await fetch(url);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    return data;
  } catch (err) {
    console.error("Fetch failed:", err);
    return null;
  }
}
```

---

## 5. Modern Operators
```javascript
// Nullish Coalescing (null or undefined only):
const port = process.env.PORT ?? 3000;

// Optional Chaining:
const city = user?.address?.city;

// Ternary:
const label = isBullish ? "🟢 BUY" : "🔴 SELL";
```
