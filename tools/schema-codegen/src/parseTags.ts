import type { Node } from 'ts-morph';

/**
 * Parse JSDoc tags for inclusion in DB/API generation and platform targeting.
 *
 * Supported tags:
 *   - @api skip | only
 *   - @db  skip | only
 *   - @platform <name> [<name>...]
 * Also supports dotted forms: @api.skip, @db.only
 *
 * Defaults to included in both (inDb=true, inApi=true) and all platforms.
 */
export function parseTags(node: Node): { inDb: boolean; inApi: boolean; platforms?: string[] } {
    let inDb = true;
    let inApi = true;
    let platforms: string[] | undefined;

    const anyNode = node as any;
    const jsDocs = typeof anyNode.getJsDocs === 'function' ? anyNode.getJsDocs() : [];

    for (const doc of jsDocs) {
      const tags = (doc as any).getTags?.() ?? [];

      for (const tag of tags) {
        const anyTag = tag as any;
        const rawName: string = anyTag.getTagNameNode?.()?.getText?.() ?? anyTag.getName?.() ?? '';
        const rawComment: string = (anyTag.getCommentText?.() ?? anyTag.getComment?.() ?? '').toString().trim();

        if (rawName === 'platform') {
            platforms = rawComment.split(/\s+/).filter(p => p);
            continue; // Continue to next tag
        }

        const [scopeRaw, dottedQual] = String(rawName).split('.');
        const scope = scopeRaw === 'api' || scopeRaw === 'db' ? scopeRaw : null;
        if (!scope) {
          continue;
        }

        const spacedFirst = rawComment.split(/\s+/)[0]?.toLowerCase() || '';
        const qual = (dottedQual || spacedFirst).toLowerCase();

        if (scope === 'api') {
          if (qual === 'skip') { inApi = false; }
          else if (qual === 'only') { inApi = true; inDb = false; }
        } else if (scope === 'db') {
          if (qual === 'skip') { inDb = false; }
          else if (qual === 'only') { inDb = true; inApi = false; }
        }
      }
    }

    return { inDb, inApi, platforms };
  }