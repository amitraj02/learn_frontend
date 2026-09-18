# 🎯 Top 25 React Interview Questions & Answers
### Essential Interview Prep for Freshers & Junior Developers
*Instructor: AI Tech Teaching Mentor*
*Location: `/Users/amitraj/tradeBOT/LEARNING_Tech_website/learn_react_simple_way`*

---

### Q1: What is React and what makes it different from other libraries?
**Answer:** React is an open-source, component-based front-end JavaScript library maintained by Meta (Facebook). It is used for building fast, interactive user interfaces for single-page applications. Unlike Vanilla JavaScript which uses imperative DOM manipulation, React is **declarative**: you define how the UI looks based on state, and React automatically updates the browser using its Virtual DOM.

---

### Q2: What is JSX and can React work without it?
**Answer:** JSX stands for *JavaScript XML*. It is a syntax extension for JavaScript that allows you to write HTML-like tags inside JS files. 
React **can** work without JSX using `React.createElement(...)`, but JSX makes code much more readable, intuitive, and maintainable. Under the hood, Babel transpiles JSX into pure `React.createElement()` function calls.

---

### Q3: What is the Virtual DOM and how does the reconciliation algorithm work?
**Answer:** The Virtual DOM is a lightweight JavaScript representation of the actual browser DOM stored in memory.
When state or props change:
1. React creates a new Virtual DOM tree.
2. It compares the new tree with the previous Virtual DOM tree using a fast heuristic algorithm called **Diffing**.
3. React computes the minimal set of DOM operations needed to update the screen.
4. It applies only those specific changes to the real DOM. This entire batch process is called **Reconciliation**.

---

### Q4: Explain the difference between Props and State.
**Answer:**
| Feature | Props (Properties) | State |
| :--- | :--- | :--- |
| **Origin** | Passed down from Parent to Child | Initialized and managed internally within the component |
| **Mutability** | **Immutable** (Read-Only) | **Mutable** (via setter function e.g. `setCount`) |
| **Scope** | External configuration | Internal component memory |
| **Ownership** | Owned by the parent | Owned exclusively by the component that declared it |

---

### Q5: Why can't we modify state directly like `state.count = 5`?
**Answer:** Because React relies on shallow reference comparison to know when to trigger a re-render. If you mutate state directly, the memory reference remains unchanged, React detects no difference, and the browser screen will **NOT** update. Always use the setter function returned by `useState` (e.g., `setCount(5)`).

---

### Q6: What are React Hooks and what are the Rules of Hooks?
**Answer:** Hooks are special functions starting with `use` (e.g., `useState`, `useEffect`, `useRef`) introduced in React 16.8 that allow functional components to use state and lifecycle features without writing ES6 class components.
**The Two Golden Rules of Hooks:**
1. **Only call hooks at the top level:** Do NOT call hooks inside loops, conditional statements (`if`), or nested functions.
2. **Only call hooks from React function components or Custom Hooks:** Do not call them in regular vanilla JavaScript helper functions.

---

### Q7: Explain the `useEffect` dependency array scenarios.
**Answer:**
1. `useEffect(() => { ... })` *(No array)*: Runs after **every single render** (mount and update).
2. `useEffect(() => { ... }, [])` *(Empty array)*: Runs **only once** after the component mounts for the first time. Ideal for initial data fetching and setting up subscriptions.
3. `useEffect(() => { ... }, [a, b])` *(With dependencies)*: Runs on initial mount, and then **only when variable `a` or `b` changes**.

---

### Q8: What does the cleanup function in `useEffect` do?
**Answer:** If you return a function from `useEffect`, React executes it when the component is about to unmount (leave the screen) or right before re-running the effect due to a dependency change. It is used to clear timers (`clearInterval`), cancel network requests, remove event listeners, and prevent memory leaks.

---

### Q9: Why is the `key` prop required in lists, and why shouldn't we use array index?
**Answer:** The `key` prop gives each DOM node a unique, persistent identifier. React's Diffing algorithm uses keys to match children between renders so it knows which items were added, removed, or re-ordered.
Using array indices (`key={index}`) breaks if items are inserted, deleted, or sorted, causing input states and animations to get mixed up. Always use a stable, unique ID (e.g., `key={user.id}`).

---

### Q10: What is Prop Drilling and how do you solve it?
**Answer:** Prop drilling occurs when you have to pass data through multiple layers of intermediate components that don't need the data themselves, solely to reach a deeply nested child.
**Solutions:**
1. **React Context API (`createContext` + `useContext`)**: Provides a global broadcast for shared state like theme, user authentication, or language.
2. **Component Composition**: Passing components as children (`props.children`).
3. **State Management Libraries**: Zustand, Redux Toolkit, or Jotai for large enterprise applications.

---

### Q11: What is the difference between `useMemo` and `useCallback`?
**Answer:**
- `useMemo`: Caches the **result of a calculation** (a calculated value). It only re-computes when dependencies change.
- `useCallback`: Caches a **function definition** (a function reference) between renders so child components that receive it don't re-render needlessly.

---

### Q12: What is the difference between Controlled and Uncontrolled Components?
**Answer:**
- **Controlled Component:** The form input's value is bound to React state via `value={state}` and updated via `onChange={e => setState(e.target.value)}`. React is the single source of truth.
- **Uncontrolled Component:** The form input stores its own state inside the traditional DOM. You access its value when needed using a `ref` (`inputRef.current.value`).

---

### Q13: What is `useRef` and when should you use it over `useState`?
**Answer:** `useRef` returns a mutable object `{ current: initialValue }` that persists across renders.
**Key differences from `useState`:** Changing `.current` **does NOT trigger a re-render**.
**Use cases:**
1. Storing direct references to DOM nodes (e.g., calling `.focus()`, measuring element width).
2. Storing timer IDs, interval references, or previous state values.

---

### Q14: What are Custom Hooks and why create them?
**Answer:** A custom hook is a JavaScript function whose name starts with `use` and that can call other React hooks. Custom hooks allow you to extract and reuse stateful logic (such as fetching data, window resizing, or syncing with `localStorage`) across multiple components without duplicating code.

---

### Q15: What is a Higher-Order Component (HOC)?
**Answer:** A Higher-Order Component is an advanced React pattern where a function takes a component as an argument and returns an enhanced new component (e.g., `withAuth(ProfileComponent)`). While common in older class-based codebases, modern React favors **Custom Hooks** for logic reuse.
