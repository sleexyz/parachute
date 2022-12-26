package controller

type DLList[T any] struct {
	first *DLListItem[T]
	last  *DLListItem[T]
}

// O(1) enqueue
func (l *DLList[T]) Enqueue(value T) *DLListItem[T] {
	oldFirst := l.first
	l.first = &DLListItem[T]{value: value, next: oldFirst}
	if oldFirst != nil {
		oldFirst.before = l.first
	}
	if l.last == nil {
		l.last = l.first
	}
	return l.first
}

// O(1) dequeue
func (l *DLList[T]) Dequeue() *DLListItem[T] {
	oldLast := l.last
	if oldLast == nil {
		panic("empty!")
	}
	l.last = oldLast.before
	if l.last != nil {
		l.last.next = nil
	}
	return oldLast
}

func (l *DLList[T]) Delete(d *DLListItem[T]) {
	if l.first == d {
		l.first = d.next
	}
	if l.last == d {
		l.last = d.before
	}
	if d.before != nil {
		d.before.next = d.next
	}
}

type DLListItem[T any] struct {
	before *DLListItem[T]
	value  T
	next   *DLListItem[T]
}

type Entry[T any] struct {
	key   string
	value T
}

type LRUCache[V any] struct {
	capacity int
	index    map[string]*DLListItem[*Entry[V]]
	queue    *DLList[*Entry[V]]
}

func InitLRUCache[V any](capacity int) *LRUCache[V] {
	return &LRUCache[V]{
		index:    make(map[string]*DLListItem[*Entry[V]]),
		capacity: capacity,
		queue:    &DLList[*Entry[V]]{},
	}
}

func (l *LRUCache[V]) Get(key string) (V, bool) {
	match, ok := l.index[key]
	if ok {
		return match.value.value, ok
	}
	var zero V
	return zero, ok
}

func (l *LRUCache[V]) Has(key string) bool {
	_, ok := l.Get(key)
	return ok
}

func (l *LRUCache[V]) Put(key string, value V) {
	oldRef, ok := l.index[key]
	if ok {
		l.queue.Delete(oldRef)
	} else {
		if len(l.index) == l.capacity {
			ref := l.queue.Dequeue()
			delete(l.index, ref.value.key)
		}
	}
	l.index[key] = l.queue.Enqueue(&Entry[V]{key: key, value: value})
}
