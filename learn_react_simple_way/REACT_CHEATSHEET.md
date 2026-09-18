# ⚡ React Fast Reference Cheatsheet
### Core Syntax, Hooks & Idioms for Beginners & Freshers
*Location: `/Users/amitraj/tradeBOT/LEARNING_Tech_website/learn_react_simple_way`*

---

## 1. Functional Component & Props
```jsx
// Destructuring props with default value
function StockBadge({ symbol, price = 0, isBullish }) {
  return (
    <div className={`badge ${isBullish ? 'green' : 'red'}`}>
      <span>{symbol}</span>
      <strong>₹{price.toFixed(2)}</strong>
    </div>
  );
}
```

## 2. Essential Hooks Cheat Table

| Hook | Purpose | Typical Syntax |
| :--- | :--- | :--- |
| `useState` | Component state memory | `const [val, setVal] = useState(init);` |
| `useEffect` | API calls, timers, subscriptions | `useEffect(() => { ... return cleanup; }, [deps]);` |
| `useRef` | Direct DOM node access / persistent ref | `const ref = useRef(null); <input ref={ref} />` |
| `useContext`| Consume global context without props | `const { theme } = useContext(ThemeContext);` |
| `useMemo` | Cache computed return value | `const val = useMemo(() => compute(a), [a]);` |
| `useCallback`| Cache function instance | `const fn = useCallback(() => doWork(), []);` |

## 3. Safe State Mutation Rules
```jsx
// ❌ WRONG: list.push(item); setList(list);
// ✔️ RIGHT: Add item
setList(prev => [...prev, newItem]);

// ✔️ RIGHT: Remove item by ID
setList(prev => prev.filter(item => item.id !== targetId));

// ✔️ RIGHT: Update property in item
setList(prev => prev.map(item => 
  item.id === targetId ? { ...item, status: 'DONE' } : item
));

// ✔️ RIGHT: Update nested object
setUser(prev => ({ ...prev, address: { ...prev.address, city: 'Mumbai' } }));
```

## 4. Conditional Rendering Patterns
```jsx
// 1. Ternary
{isLoaded ? <Chart /> : <Spinner />}

// 2. Short-circuit AND
{hasAlerts && <NotificationBell />}

// 3. Fallback with Nullish Coalescing
<p>{username ?? 'Anonymous Trader'}</p>
```

## 5. Controlled Form Input
```jsx
const [ticker, setTicker] = useState('');

<input 
  value={ticker} 
  onChange={e => setTicker(e.target.value)} 
  placeholder="Enter stock..."
/>
```
