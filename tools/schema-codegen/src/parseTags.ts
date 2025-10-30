import type { Node } from 'ts-morph';

/**
 * Parse JSDoc tags for inclusion in DB/API generation.
 *
 * Supported tags:
 *   - @api skip | only
 *   - @db  skip | only
 * Also supports dotted forms: @api.skip, @db.only
 *
 * Defaults to included in both (inDb=true, inApi=true).
 */
export function parseTags(node: Node): { inDb: boolean; inApi: boolean } {
    console.log('[parseTags] Starting parse for node');
    let inDb = true;
    let inApi = true;

    const anyNode = node as any;
    const jsDocs = typeof anyNode.getJsDocs === 'function' ? anyNode.getJsDocs() : [];
    console.log(`[parseTags] Found ${jsDocs.length} JSDoc blocks`);

    for (const doc of jsDocs) {
      const tags = (doc as any).getTags?.() ?? [];
      console.log(`[parseTags] Found ${tags.length} tags in JSDoc`);

      for (const tag of tags) {
        const anyTag = tag as any;
        const rawName: string = anyTag.getTagNameNode?.()?.getText?.() ?? anyTag.getName?.() ?? '';
        const rawComment: string = (anyTag.getCommentText?.() ?? anyTag.getComment?.() ?? '').toString().trim();
        console.log(`[parseTags] Tag: name="${rawName}", comment="${rawComment}"`);

        const [scopeRaw, dottedQual] = String(rawName).split('.');
        const scope = scopeRaw === 'api' || scopeRaw === 'db' ? scopeRaw : null;
        console.log(`[parseTags] Parsed: scopeRaw="${scopeRaw}", dottedQual="${dottedQual}", scope="${scope}"`);
        if (!scope) {
          console.log('[parseTags] Skipping - not api/db scope');
          continue;
        }

        const spacedFirst = rawComment.split(/\s+/)[0]?.toLowerCase() || '';
        const qual = (dottedQual || spacedFirst).toLowerCase();
        console.log(`[parseTags] Qualifier: "${qual}"`);

        if (scope === 'api') {
          if (qual === 'skip') { inApi = false; console.log('[parseTags] Set inApi=false'); }
          else if (qual === 'only') { inApi = true; inDb = false; console.log('[parseTags] Set inApi=true, inDb=false'); }
        } else if (scope === 'db') {
          if (qual === 'skip') { inDb = false; console.log('[parseTags] Set inDb=false'); }
          else if (qual === 'only') { inDb = true; inApi = false; console.log('[parseTags] Set inDb=true, inApi=false'); }
        }
      }
    }

    console.log(`[parseTags] Final result: inDb=${inDb}, inApi=${inApi}\n`);
    return { inDb, inApi };
  }