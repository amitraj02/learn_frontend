# 🎯 Top 25 JavaScript Interview Questions & Answers
### Essential Interview Prep for Freshers & Frontend Developers
*Instructor: AI Tech Teaching Mentor*
*Location: `/Users/amitraj/tradeBOT/LEARNING_Tech_website/learn_javascript_simpleWay`*

---

### Q1: What is a Closure in JavaScript and why is it useful?
**Answer:** A closure is the combination of a function bundled together with references to its surrounding lexical state (the lexical environment). In JavaScript, closures are created every time a function is created, at function creation time.
Closures give inner functions access to an outer function's variables even after the outer function has returned. They are commonly used for data privacy (private variables), function factories, and memoization.

---

### Q2: Explain the Event Loop, Call Stack, and Task Queues.
**Answer:** JavaScript is single-threaded with one Call Stack. When asynchronous operations (like `setTimeout` or `fetch`) complete, their callback functions are placed in queues:
- **Microtask Queue (Higher Priority):** Handlers for Promises (`.then`, `await`), `MutationObserver`, `queueMicrotask`.
- **Macrotask / Callback Queue (Lower Priority):** `setTimeout`, `setInterval`, DOM UI events.
The **Event Loop** continuously checks if the Call Stack is empty. When empty, it drains all Microtasks first before executing the next Macrotask.

---

### Q3: What is the difference between `==` and `===`?
**Answer:**
- `==` (Loose Equality): Compares values after performing implicit type coercion if the types are different (e.g., `5 == '5'` is `true`, `0 == false` is `true`).
- `===` (Strict Equality): Compares both value and type without coercion (e.g., `5 === '5'` is `false`). Always use `===`.

---

### Q4: Explain the difference between `let`, `const`, and `var`.
**Answer:**
- `var`: Function-scoped, hoisted and initialized with `undefined`, can be redeclared.
- `let`: Block-scoped (`{}`), hoisted into the Temporal Dead Zone (TDZ) where accessing it before declaration throws a `ReferenceError`, can be reassigned.
- `const`: Block-scoped, in TDZ until declared, cannot be reassigned once initialized.

---

### Q5: How does the `this` keyword work in regular functions vs arrow functions?
**Answer:**
- In regular functions, `this` is dynamically determined by **how the function is called** (the calling context).
- In arrow functions, `this` is **lexically bound**; it inherits `this` from the surrounding scope where the arrow function was defined, and cannot be rebound using `.bind()`, `.call()`, or `.apply()`.

---

### Q6: What is the difference between `null` and `undefined`?
**Answer:**
- `undefined`: The default value assigned by JavaScript to variables that have been declared but not assigned a value, or functions that return nothing.
- `null`: An intentional assignment indicating "no value" or "empty object reference". Note: `typeof null === 'object'` due to an original JavaScript bug.

---

### Q7: What is Debouncing and Throttling?
**Answer:**
- **Debouncing:** Delays execution of a function until a certain amount of idle time has passed since the last event (e.g. search input autocomplete).
- **Throttling:** Ensures a function is called at most once in a specified time interval, regardless of how many times the user fires the event (e.g. window resize or scroll handler).

---

### Q8: Explain Prototypal Inheritance in JavaScript.
**Answer:** In JavaScript, every object has an internal link to another object called its **prototype** (`[[Prototype]]` or accessed via `Object.getPrototypeOf(obj)`). When accessing a property on an object, JavaScript searches the object itself; if not found, it traverses up the prototype chain until it finds the property or reaches `null`.

---

### Q9: What is the difference between `.map()` and `.forEach()`?
**Answer:**
- `.map()`: Transforms elements and returns a **new array** of the same length without mutating the original array.
- `.forEach()`: Executes a callback on each element for side effects and **returns `undefined`**.

---

### Q10: What are Promises and how do they solve "Callback Hell"?
**Answer:** A Promise represents the eventual completion or failure of an asynchronous operation and its resulting value. It has three states: `pending`, `fulfilled`, or `rejected`. Promises allow chaining with `.then()` and `.catch()`, or clean linear syntax with `async/await`, avoiding deeply nested "pyramid of doom" callbacks.
