export const ROLE_VIEWER = 0
export const ROLE_COMMENTER = 1
export const ROLE_EDITOR = 2
export const ROLE_OWNER = 3

export function roleLabel(role: number): string {
  switch (role) {
    case ROLE_OWNER:
      return '所有者'
    case ROLE_EDITOR:
      return '编辑者'
    case ROLE_COMMENTER:
      return '评论者'
    default:
      return '阅读者'
  }
}
