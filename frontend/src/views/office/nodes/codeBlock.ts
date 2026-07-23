import hljs from 'highlight.js'
import type { NodeViewConstructor } from 'prosemirror-view'

const COMMON_LANGS = [
  { value: '', label: '纯文本' },
  { value: 'javascript', label: 'JavaScript' },
  { value: 'typescript', label: 'TypeScript' },
  { value: 'python', label: 'Python' },
  { value: 'rust', label: 'Rust' },
  { value: 'go', label: 'Go' },
  { value: 'java', label: 'Java' },
  { value: 'kotlin', label: 'Kotlin' },
  { value: 'swift', label: 'Swift' },
  { value: 'cpp', label: 'C++' },
  { value: 'c', label: 'C' },
  { value: 'css', label: 'CSS' },
  { value: 'html', label: 'HTML' },
  { value: 'sql', label: 'SQL' },
  { value: 'bash', label: 'Bash' },
  { value: 'json', label: 'JSON' },
  { value: 'yaml', label: 'YAML' },
  { value: 'xml', label: 'XML' },
  { value: 'markdown', label: 'Markdown' },
  { value: 'dart', label: 'Dart' },
  { value: 'ruby', label: 'Ruby' },
  { value: 'php', label: 'PHP' },
  { value: 'dockerfile', label: 'Dockerfile' },
  { value: 'diff', label: 'Diff' },
]

export function createCodeBlockView(): NodeViewConstructor {
  return (node, view, getPos) => {
    const dom = document.createElement('div')
    dom.className = 'code-block-wrapper'

    const toolbar = document.createElement('div')
    toolbar.className = 'code-block-toolbar'

    const langSelect = document.createElement('select')
    langSelect.className = 'code-lang-select'

    COMMON_LANGS.forEach(({ value, label }) => {
      const opt = document.createElement('option')
      opt.value = value
      opt.textContent = label
      if (value === node.attrs.language) opt.selected = true
      langSelect.appendChild(opt)
    })

    langSelect.addEventListener('change', () => {
      const pos = getPos()
      if (typeof pos === 'number') {
        view.dispatch(view.state.tr.setNodeMarkup(pos, undefined, { language: langSelect.value }))
      }
    })

    const copyBtn = document.createElement('button')
    copyBtn.className = 'code-copy-btn'
    copyBtn.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>'
    copyBtn.title = '复制代码'

    copyBtn.addEventListener('click', async () => {
      const text = node.textContent
      try {
        await navigator.clipboard.writeText(text)
        copyBtn.innerHTML = '<span style="color:#4caf50">\u2713</span>'
        copyBtn.title = '已复制'
        setTimeout(() => {
          copyBtn.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>'
          copyBtn.title = '复制代码'
        }, 2000)
      } catch {
        copyBtn.textContent = '复制失败'
        setTimeout(() => { copyBtn.textContent = '复制' }, 2000)
      }
    })

    toolbar.appendChild(langSelect)
    toolbar.appendChild(copyBtn)

    const pre = document.createElement('pre')
    const code = document.createElement('code')
    code.className = node.attrs.language ? 'language-' + node.attrs.language : ''
    pre.appendChild(code)

    dom.appendChild(toolbar)
    dom.appendChild(pre)

    function highlight() {
      const lang = node.attrs.language
      if (!lang) return
      try {
        hljs.highlightElement(code)
      } catch {
        // highlight.js may fail if language not registered
      }
    }

    return {
      dom,
      contentDOM: code,
      update: (updatedNode) => {
        if (updatedNode.type.name !== 'codeBlock') return false
        node = updatedNode
        const lang = node.attrs.language
        langSelect.value = lang
        code.className = lang ? 'language-' + lang : ''
        if (lang) {
          // Schedule after ProseMirror updates content
          requestAnimationFrame(highlight)
        }
        return true
      },
      ignoreMutation: (mutation) => {
        if (mutation.type === 'childList') return true
        if (mutation.type === 'attributes' && mutation.attributeName === 'data-highlighted') return true
        return false
      },
    }
  }
}
